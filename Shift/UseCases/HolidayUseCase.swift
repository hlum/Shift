//
//  HolidayUseCase.swift
//  Shift
//
//  Created by cmStudent on 2025/05/14.
//

import Foundation

class HolidayUseCase {
    private let holidayRepository: HolidayRepository
    
    private var publicHolidays: [Holiday] = []
    private let countryCode: String
    
    init(holidayRepository: HolidayRepository, countryCode: String) {
        self.holidayRepository = holidayRepository
        self.countryCode = countryCode
        Task { @MainActor in
            await self.loadPublicHolidays()
        }
    }
    
    @MainActor
    private func loadPublicHolidays() async {
        do {
            self.publicHolidays = try await holidayRepository.fetchHolidays(countryCode: countryCode)
        } catch {
            Logger.standard.error("Error loading public holidays: \(error.localizedDescription)")
        }
    }
    
    func fetchHolidays() -> [Holiday] {
        return self.publicHolidays
    }
    
    func fetchHoliday(for date: Date) -> [Holiday] {
        let result = publicHolidays.filter { holiday in
            Calendar.current.isDate(holiday.date, inSameDayAs: date)
        }
        return result
    }
    
    func isWeekend(_ date: Date) -> Bool {
        return Calendar.current.isDateInWeekend(date)
    }
    
    
}

class MockHolidayUseCase: HolidayUseCase {
    init() {
        super.init(holidayRepository: MockHolidayRepo(), countryCode: "JP")
    }
}

