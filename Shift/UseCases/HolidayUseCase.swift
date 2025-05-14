//
//  HolidayUseCase.swift
//  Shift
//
//  Created by cmStudent on 2025/05/14.
//

import Foundation

class HolidayUseCase {
    private let holidayRepository: HolidayRepository
    
    init(holidayRepository: HolidayRepository) {
        self.holidayRepository = holidayRepository
    }
    
    func fetchHolidays(countryCode: String) async throws -> [Holiday] {
        return try await holidayRepository.fetchHolidays(countryCode: countryCode)
    }
    
    func fetchHoliday(for date: Date, countryCode: String) async throws -> [Holiday] {
        return try await holidayRepository.fetchHolidays(for: date, countryCode: countryCode)
    }
    
    
}

class MockHolidayUseCase: HolidayUseCase {
    init() {
        super.init(holidayRepository: MockHolidayRepo())
    }
}

