//
//  MockHolidayAPIClient.swift
//  ShiftTests
//
//  Created by cmStudent on 2025/05/17.
//

import Foundation

class MockHolidayAPIClient: HolidayAPIClientProtocol {
    private let holidays: [HolidayAPIResponse] = [
        // --- 2024 ---
         HolidayAPIResponse(name: "New Year's Day", dateString: "2024-01-01", countryCode: "JP"),
         HolidayAPIResponse(name: "New Year's Day", dateString: "2024-01-01", countryCode: "US"),
         HolidayAPIResponse(name: "New Year's Day", dateString: "2024-01-01", countryCode: "DE"),
         
        // Japan (JP) Holidays
        HolidayAPIResponse(name: "New Year's Day", dateString: "2025-01-01", countryCode: "JP"),
        HolidayAPIResponse(name: "Coming of Age Day", dateString: "2025-01-13", countryCode: "JP"),
        HolidayAPIResponse(name: "National Foundation Day", dateString: "2025-02-11", countryCode: "JP"),
        HolidayAPIResponse(name: "Vernal Equinox Day", dateString: "2025-03-20", countryCode: "JP"),
        HolidayAPIResponse(name: "Showa Day", dateString: "2025-04-29", countryCode: "JP"),
        HolidayAPIResponse(name: "Constitution Memorial Day", dateString: "2025-05-03", countryCode: "JP"),
        HolidayAPIResponse(name: "Greenery Day", dateString: "2025-05-04", countryCode: "JP"),
        HolidayAPIResponse(name: "Children's Day", dateString: "2025-05-05", countryCode: "JP"),
        HolidayAPIResponse(name: "Marine Day", dateString: "2025-07-21", countryCode: "JP"),
        HolidayAPIResponse(name: "Mountain Day", dateString: "2025-08-11", countryCode: "JP"),
        HolidayAPIResponse(name: "Respect for the Aged Day", dateString: "2025-09-15", countryCode: "JP"),
        HolidayAPIResponse(name: "Autumnal Equinox Day", dateString: "2025-09-23", countryCode: "JP"),
        HolidayAPIResponse(name: "Health and Sports Day", dateString: "2025-10-13", countryCode: "JP"),
        HolidayAPIResponse(name: "Culture Day", dateString: "2025-11-03", countryCode: "JP"),
        HolidayAPIResponse(name: "Labor Thanksgiving Day", dateString: "2025-11-23", countryCode: "JP"),
        HolidayAPIResponse(name: "Emperor's Birthday", dateString: "2025-12-23", countryCode: "JP"),
        
        // United States (US) Holidays
        HolidayAPIResponse(name: "New Year's Day", dateString: "2025-01-01", countryCode: "US"),
        HolidayAPIResponse(name: "Martin Luther King Jr. Day", dateString: "2025-01-20", countryCode: "US"),
        HolidayAPIResponse(name: "Presidents Day", dateString: "2025-02-17", countryCode: "US"),
        HolidayAPIResponse(name: "Memorial Day", dateString: "2025-05-26", countryCode: "US"),
        HolidayAPIResponse(name: "Juneteenth", dateString: "2025-06-19", countryCode: "US"),
        HolidayAPIResponse(name: "Independence Day", dateString: "2025-07-04", countryCode: "US"),
        HolidayAPIResponse(name: "Labor Day", dateString: "2025-09-01", countryCode: "US"),
        HolidayAPIResponse(name: "Columbus Day", dateString: "2025-10-13", countryCode: "US"),
        HolidayAPIResponse(name: "Veterans Day", dateString: "2025-11-11", countryCode: "US"),
        HolidayAPIResponse(name: "Thanksgiving Day", dateString: "2025-11-27", countryCode: "US"),
        HolidayAPIResponse(name: "Christmas Day", dateString: "2025-12-25", countryCode: "US"),
        
        // Germany (DE) Holidays
        HolidayAPIResponse(name: "New Year's Day", dateString: "2025-01-01", countryCode: "DE"),
        HolidayAPIResponse(name: "Good Friday", dateString: "2025-04-18", countryCode: "DE"),
        HolidayAPIResponse(name: "Easter Monday", dateString: "2025-04-21", countryCode: "DE"),
        HolidayAPIResponse(name: "Labour Day", dateString: "2025-05-01", countryCode: "DE"),
        HolidayAPIResponse(name: "Ascension Day", dateString: "2025-05-29", countryCode: "DE"),
        HolidayAPIResponse(name: "Whit Monday", dateString: "2025-06-09", countryCode: "DE"),
        HolidayAPIResponse(name: "German Unity Day", dateString: "2025-10-03", countryCode: "DE"),
        HolidayAPIResponse(name: "Christmas Day", dateString: "2025-12-25", countryCode: "DE"),
        HolidayAPIResponse(name: "St. Stephen's Day", dateString: "2025-12-26", countryCode: "DE"),
         // --- 2026 ---
         HolidayAPIResponse(name: "New Year's Day", dateString: "2026-01-01", countryCode: "JP"),
         HolidayAPIResponse(name: "New Year's Day", dateString: "2026-01-01", countryCode: "US"),
         HolidayAPIResponse(name: "New Year's Day", dateString: "2026-01-01", countryCode: "DE")
    ]
    
    func getAllHolidays() -> [HolidayAPIResponse] {
        return holidays
    }
    
    func checkTheData(date: Date, countryCode: String) -> [Holiday] {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        let dateString = formatter.string(from: date)
        
        return holidays.filter { holiday in
            holiday.dateString == dateString &&
            holiday.countryCode == countryCode
        }.map { holiday in
            Holiday(holidayApiResponse: holiday)
        }
    }
    
    func fetchHolidays(year: Int, countryCode: String) async throws -> [HolidayAPIResponse] {
        try await Task.sleep(nanoseconds: 1)
        return holidays.filter { holiday in
            holiday.dateString.hasPrefix("\(year)") &&
            holiday.countryCode == countryCode
        }
    }
}
