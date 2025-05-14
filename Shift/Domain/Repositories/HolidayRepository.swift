//
//  HolidayAPIRepository.swift
//  Shift
//
//  Created by cmStudent on 2025/05/13.
//

import Foundation

protocol HolidayRepository {
    func fetchHolidays(for year: Int, countryCode: String) async throws -> [Holiday]
    func isHolidayDataLoaded(for year: Int) async throws -> Bool
}
