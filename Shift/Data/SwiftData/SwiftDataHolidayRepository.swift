import Foundation
import SwiftData

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
    
    func fetchHolidays(for date: Date, countryCode: String) async throws -> [Holiday] {
        
        let currentYear = calendar.component(.year, from: date)
        try await checkAndLoadHolidaysLastCurrentNextYear(for: currentYear, countryCode: countryCode)
        
        
        let day = calendar.component(.day, from: date)
        guard let startOfDay = calendar.date(from: DateComponents(day: day, hour: 0, minute: 0, second: 0)),
              let startOfTomorrow = calendar.date(from: DateComponents(day: day + 1, hour: 0, minute: 0,second: 0)) else {
            print("Can't create startOfDay or startOfTomorrow")
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
    
    
    func fetchHolidays(countryCode: String) async throws -> [Holiday] {
        let currentYear = calendar.component(.year, from: Date())
        try await checkAndLoadHolidaysLastCurrentNextYear(for: currentYear, countryCode: countryCode)
        
        let descriptor = FetchDescriptor<Holiday>()
        return try context.fetch(descriptor)
    }
    
 
}


extension SwiftDataHolidayRepository {
    private func checkAndLoadHolidaysLastCurrentNextYear(for year: Int, countryCode: String) async throws  {
        let (last, current, next) = try await isAllThreeYearHolidayDataLoaded(currentYear: year)
        
        if last && current && next {
            print("All three year holiday data already loaded for year: \(year) \(countryCode)")
            return
        }
        
        var holidays: [HolidayAPIResponse] = []
        
        if !last { holidays += try await apiClient.fetchHolidays(year: year-1, countryCode: countryCode)  }
        if !current { holidays += try await apiClient.fetchHolidays(year: year, countryCode: countryCode)  }
        if !next { holidays += try await apiClient.fetchHolidays(year: year+1, countryCode: countryCode)  }
        
        try await saveHolidaysToLocalStorage(apiResponse: holidays)
    }
    
    private func isAllThreeYearHolidayDataLoaded(currentYear: Int) async throws -> (Bool, Bool, Bool) {
        return (
            try await holidayDataLoaded(for: currentYear - 1),
            try await holidayDataLoaded(for: currentYear),
            try await holidayDataLoaded(for: currentYear + 1)
        )
    }


    private func holidayDataLoaded(for year: Int) async throws -> Bool {
        guard
            let startOfYear = calendar.date(from: DateComponents(year: year, month: 1, day: 1)),
            let startOfNextYear = calendar.date(from: DateComponents(year: year + 1, month: 1, day: 1))
        else {
            return false
        }
        
        let predicate = #Predicate<Holiday> { holiday in
             holiday.date >= startOfYear && holiday.date < startOfNextYear
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
        print("holidays saved to swiftData count: \(holidays.count)")
        try context.save()
        return holidays
    }
}
