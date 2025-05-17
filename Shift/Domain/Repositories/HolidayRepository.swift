//
//  HolidayAPIRepository.swift
//  Shift
//
//  Created by cmStudent on 2025/05/13.
//

import Foundation

protocol HolidayRepository {
    func fetchHolidays(for date: Date, countryCode: String) async throws -> [Holiday]
    func fetchHolidays(countryCode: String) async throws -> [Holiday]
    func fetchHolidays(between dateInterval: DateInterval, countryCode: String) async throws -> [Holiday]
}
