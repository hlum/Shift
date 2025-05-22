import Foundation
import SwiftData

@MainActor
final class SwiftDataHolidayRepository: HolidayRepository {
    private let context: ModelContext
    private let apiClient: HolidayAPIClientProtocol
    private let calendar: Calendar
    
    init(
        context: ModelContext,
        apiClient: HolidayAPIClientProtocol,
        calendar: Calendar = .current
    ) {
        self.context = context
        self.apiClient = apiClient
        self.calendar = calendar
    }
    
    @MainActor
    func fetchHolidays(for date: Date, countryCode: String) async throws -> [Holiday] {
        print("Country Code: \(countryCode)")
        let currentYear = calendar.component(.year, from: date)
        try await checkAndLoadHolidaysLastCurrentNextYear(for: currentYear, countryCode: countryCode)
        
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        
        guard let startOfDay = calendar.date(from: DateComponents(year: components.year ,month: components.month, day: components.day, hour: 0, minute: 0, second: 0)),
              let startOfTomorrow = calendar.date(from: DateComponents(year: components.year ,month: components.month, day: components.day! + 1, hour: 0, minute: 0,second: 0)) else {
            Logger.standard.fault("Can't create startOfDay or startOfTomorrow")
            return []
        }

        
        let predicate = #Predicate<Holiday> { holiday in
            holiday.date >= startOfDay && holiday.date < startOfTomorrow &&
            holiday.countryCode == countryCode
        }
        
        let descriptor = FetchDescriptor<Holiday>(predicate: predicate)
        let holidays = try context.fetch(descriptor)
        return holidays
    }
    
    @MainActor
    func fetchHolidays(countryCode: String) async throws -> [Holiday] {
        let currentYear = calendar.component(.year, from: Date())
        try await checkAndLoadHolidaysLastCurrentNextYear(for: currentYear, countryCode: countryCode)
        let predicate = #Predicate<Holiday> { holiday in
            holiday.countryCode == countryCode
        }
        let descriptor = FetchDescriptor<Holiday>(predicate: predicate)
        return try context.fetch(descriptor)
    }
    
    @MainActor
    func fetchHolidays(between dateInterval: DateInterval, countryCode: String) async throws -> [Holiday] {
        
        let startDateComponents = calendar.dateComponents([.year, .month, .day], from: dateInterval.start)
        let endDateComponents = calendar.dateComponents([.year, .month, .day], from: dateInterval.end)
        
        
        guard let startOfDay = calendar.date(
            from: DateComponents(
                year: startDateComponents.year ,
                month: startDateComponents.month,
                day: startDateComponents.day,
                hour: 0,
                minute: 0,
                second: 0
            )
        ),
              let startOfTomorrow = calendar.date(
                from: DateComponents(
                    year: endDateComponents.year ,
                    month: endDateComponents.month,
                    day: endDateComponents.day! + 1,
                    hour: 0,
                    minute: 0,
                    second: 0
                )
              ) else {
            Logger.standard.fault("Can't create startOfDay or startOfTomorrow")
            return []
        }
        
        let predicate = #Predicate<Holiday> { holiday in
            holiday.date >= startOfDay && holiday.date < startOfTomorrow &&
            holiday.countryCode == countryCode
        }
        
        let descriptor = FetchDescriptor<Holiday>(predicate: predicate)
        let holidays = try context.fetch(descriptor)
        return holidays
        
    }
    
 
}


extension SwiftDataHolidayRepository {
    private func checkAndLoadHolidaysLastCurrentNextYear(for year: Int, countryCode: String) async throws  {
        let (last, current, next) = try await isAllThreeYearHolidayDataLoaded(currentYear: year, countryCode: countryCode)
        
        if last && current && next {
            Logger.standard.info("All three year holiday data already loaded for year: \(year) \(countryCode)")
            return
        }
        
        var holidays: [HolidayAPIResponse] = []
        
        if !last { holidays += try await apiClient.fetchHolidays(year: year-1, countryCode: countryCode)  }
        if !current { holidays += try await apiClient.fetchHolidays(year: year, countryCode: countryCode)  }
        if !next { holidays += try await apiClient.fetchHolidays(year: year+1, countryCode: countryCode)  }
        
        try await saveHolidaysToLocalStorage(apiResponse: holidays)
    }
    
    private func isAllThreeYearHolidayDataLoaded(currentYear: Int, countryCode: String) async throws -> (Bool, Bool, Bool) {
        return (
            try await holidayDataLoaded(for: currentYear - 1, countryCode: countryCode),
            try await holidayDataLoaded(for: currentYear, countryCode: countryCode),
            try await holidayDataLoaded(for: currentYear + 1, countryCode: countryCode)
        )
    }


    private func holidayDataLoaded(for year: Int, countryCode: String) async throws -> Bool {
        guard
            let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
            let startOfNextYear = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))
        else {
            return false
        }
        
        let predicate = #Predicate<Holiday> { holiday in
             holiday.date >= startOfYear && holiday.date < startOfNextYear &&
            holiday.countryCode == countryCode
         }
        
        let descriptor = FetchDescriptor<Holiday>(predicate: predicate)
        let count = try context.fetchCount(descriptor)
        return count > 0
    }
    
    private func fetchHolidaysFromLocalStorage(year: Int, countryCode: String) async throws -> [Holiday] {
        guard
            let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
            let startOfNextYear = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))
        else {
            return []
        }
        
        let predicate = #Predicate<Holiday> { holiday in
            holiday.date >= startOfYear && holiday.date < startOfNextYear &&
            holiday.countryCode == countryCode
        }
        
        let descriptor = FetchDescriptor<Holiday>(predicate: predicate)
        return try context.fetch(descriptor)
    }
    
    @discardableResult
    private func saveHolidaysToLocalStorage(apiResponse: [HolidayAPIResponse]) async throws -> [Holiday] {
        var holidays: [Holiday] = []
        
        for response in apiResponse {
            let model = Holiday(holidayApiResponse: response)
            context.insert(model)
            holidays.append(model)
        }
        Logger.standard.info("holidays saved to swiftData count: \(holidays.count)")
        try context.save()
        return holidays
    }
}
