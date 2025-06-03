//
//  HolidayUseCaseTest.swift
//  ShiftTests
//
//  Created by cmStudent on 2025/05/17.
//

import Testing
import SwiftData
import Foundation
@testable import Shift

@Suite("HolidayUseCaseTest")
struct HolidayUseCaseTest {
    // Shared mock client for consistency
    let mockClient = MockHolidayAPIClient()
    var container: ModelContainer?
    
    init() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Holiday.self, configurations: config)
    }
    
    @MainActor
    @Test("holiday fetching test")
    func test_holiday_fetching() async throws {
        // given
        guard let container = container else {
            throw TestError.containerNotInitialized
        }
        let context = container.mainContext
        let repo = SwiftDataHolidayRepository(context: context, apiClient: mockClient)
        let realHolidayDatas = getTestData()
        
        for _ in 1...100 {
            // Randomize date and country code
            let randomHoliday = realHolidayDatas.randomElement()!
            let randomCountryCode = randomHoliday.countryCode
            let randomDateString = randomHoliday.dateString
            let currentDate = changeToDate(dateString: randomHoliday.dateString)
            
            // when
            let holidays = try await repo.fetchHolidays(for: currentDate, countryCode: randomCountryCode)
            let realHolidays = mockClient.checkTheData(date: currentDate, countryCode: randomCountryCode)
            
            // then
            #expect(!holidays.isEmpty, "Holidays should not be empty for \(randomCountryCode) on \(randomDateString)")
            #expect(!realHolidays.isEmpty, "Real holidays should not be empty for \(randomCountryCode) on \(randomDateString)")
            #expect(holidays.first?.name == realHolidays.first?.name, "Holiday names should match for \(randomCountryCode) on \(randomDateString)")
        }
    }

    @MainActor
    @Test("holiday data loading test")
    func test_holiday_data_loading() async throws {
        // given
        guard let container = container else {
            throw TestError.containerNotInitialized
        }
        
        let context = container.mainContext
        let repo = SwiftDataHolidayRepository(context: context, apiClient: mockClient)
        let realHolidays = getTestData()
        
        for _ in 1...100 {
            
            let randomHoliday = realHolidays.randomElement()!
            
            
            // when
            let holidays = try await repo.fetchHolidays(countryCode: randomHoliday.countryCode)
            
            // then
            #expect(!holidays.isEmpty, "Should load holidays for the entire year")
            #expect(holidays.allSatisfy { $0.countryCode == randomHoliday.countryCode }, "All holidays should be for \(randomHoliday.countryCode)")
        }
    }
    
    private func changeToDate(dateString: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)!
    }
    
    
    private func getTestData() -> [HolidayAPIResponse] {
        return mockClient.getAllHolidays()
    }
}




// MARK: - Test Errors
enum TestError: Error {
    case containerNotInitialized
}
