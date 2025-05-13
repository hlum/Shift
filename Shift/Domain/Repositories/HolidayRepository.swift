//
//  HolidayAPIRepository.swift
//  Shift
//
//  Created by cmStudent on 2025/05/13.
//

import Foundation

protocol HolidayAPIRepository {
    func fetchHolidays(countryCode: String, year: Int) throws -> [Holiday]
}
