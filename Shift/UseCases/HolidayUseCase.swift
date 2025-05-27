//
//  HolidayUseCase.swift
//  Shift
//
//  Created by cmStudent on 2025/05/14.
//


import Foundation

protocol HolidayUseCaseProtocol {
    func fetchHolidays() async -> [Holiday]
    func fetchHolidays(between dateInterval: DateInterval) async -> [Holiday]
    func fetchHolidaysAndWeekends(between dateInterval: DateInterval) async -> [Date]
    func isWeekend(_ date: Date) -> Bool
    func fetchWeekend(between dateInterval: DateInterval) -> [Date]
    func getDateBeforeHoliday(_ date: Date) async -> Date
    func getDateAfterHoliday(_ date: Date) async -> Date
}

class HolidayUseCase: HolidayUseCaseProtocol{
    private let holidayRepository: HolidayRepository
    
    private let countryCode: String = Locale.current.region?.identifier ?? "US"
    
    init(holidayRepository: HolidayRepository) {
        self.holidayRepository = holidayRepository
    }
    
    func fetchHolidays() async -> [Holiday] {
        do {
            return try await holidayRepository.fetchHolidays(countryCode: countryCode)
        } catch {
            print("Error fetching holidays: \(error.localizedDescription)")
            return []
        }
    }
    
    func fetchHolidays(between dateInterval: DateInterval) async -> [Holiday] {
        do {
            return try await holidayRepository.fetchHolidays(between: dateInterval, countryCode: countryCode)
        } catch {
            print("Error fetching holidays: \(error.localizedDescription)")
            return []
        }
    }

    
    
    func fetchHolidaysAndWeekends(between dateInterval: DateInterval) async -> [Date] {
        do {
            let holidays = try await holidayRepository.fetchHolidays(between: dateInterval, countryCode: countryCode).map{$0.date}
            let weekends = fetchWeekend(between: dateInterval)
            return Array(Set(holidays + weekends))
        } catch {
            print("Error fetching holidays: \(error.localizedDescription)")
            return []
        }
    }
    
    
    func getDateBeforeHoliday(_ date: Date) async -> Date {
        var currentDate = date
        
        while await isWeekendOrHoliday(currentDate) {
            currentDate = Calendar.current.date(byAdding: .day, value: -1, to: currentDate)!
        }
        
        return currentDate
    }
    
    
    func getDateAfterHoliday(_ date: Date) async -> Date {
        var currentDate = date
        
        while await isWeekendOrHoliday(currentDate) {
            currentDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate)!
        }
        
        return currentDate
    }
    
    
    private func isWeekendOrHoliday(_ date: Date) async -> Bool {
        let holidayCount = await fetchHolidays(between: DateInterval(start: date, end: date.startOfNextDay()))
        return isWeekend(date) || holidayCount.count > 0
    }
    
    
    func isWeekend(_ date: Date) -> Bool {
        return Calendar.current.isDateInWeekend(date)
    }
    
    
    func fetchWeekend(between dateInterval: DateInterval) -> [Date] {
        var weekends: [Date] = []
        let calendar = Calendar.current
        var currentDate = calendar.startOfDay(for: dateInterval.start)
        let endDate = calendar.startOfDay(for: dateInterval.end)
        
        while currentDate <= endDate {
            
            if isWeekend(currentDate) {
                weekends.append(currentDate)
            }
            guard let nextDate = calendar.date(byAdding: .day, value: 1, to: currentDate) else {
                break
            }
            currentDate = nextDate
        }
        return weekends
    }

    
    
}

class MockHolidayUseCase: HolidayUseCase {
    init() {
        super.init(holidayRepository: MockHolidayRepo())
    }
}

