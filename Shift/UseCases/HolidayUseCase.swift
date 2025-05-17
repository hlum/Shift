//
//  HolidayUseCase.swift
//  Shift
//
//  Created by cmStudent on 2025/05/14.
//

import Foundation

class HolidayUseCase {
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
    
    func fetchHoliday(for date: Date) async -> [Holiday] {
        do {
            return try await holidayRepository.fetchHolidays(for: date, countryCode: countryCode)
        } catch {
            print("Error fetching holidays: \(error.localizedDescription)")
            return []
        }
    }
    
    func isWeekend(_ date: Date) -> Bool {
        return Calendar.current.isDateInWeekend(date)
    }
    
    
}

class MockHolidayUseCase: HolidayUseCase {
    init() {
        super.init(holidayRepository: MockHolidayRepo())
    }
}

