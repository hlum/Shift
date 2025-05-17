//
//  MockHolidayRepo.swift
//  Shift
//
//  Created by cmStudent on 2025/05/14.
//

import Foundation

final class MockHolidayRepo: HolidayRepository {
    func fetchHolidays(between dateInterval: DateInterval, countryCode: String) async throws -> [Holiday] {
        return holidays
    }
    
    let holidays: [Holiday] = [
        Holiday(name: "こどもの日", date: Calendar.current.date(byAdding: .day,value: 1, to: Date())!, countryCode: "JP"),
        Holiday(name: "〜の日", date: Calendar.current.date(byAdding: .day,value: 3, to: Date())!, countryCode: "JP")

    ]
    func fetchHolidays(for date: Date, countryCode: String) async throws -> [Holiday] {
        return holidays
    }
    
    func fetchHolidays(countryCode: String) async throws -> [Holiday] {
        return holidays
    }
    
    
}
