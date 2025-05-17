//
//  SwiftDataCompanyRepoTests.swift
//  ShiftTests
//
//  Created by cmStudent on 2025/05/16.
//

import Testing
import SwiftData
import Foundation

@Suite("SwiftDataCompanyRepoTests")
struct SwiftDataCompanyRepoTests {
    let company = Company(
       name: "Test2Company",
       color: .blue,
       endDate: .endOfMonth,
       payDay: PayDay(
        payDay: .day(15),
        payTiming: .nextMonth,
           holidayPayDayChange: false,
           holidayPayEarly: false
       ) ,
       salary: Salary(
           baseSalary: 1400,
           transportationExpense: 360,
           holidaySalary: 1400,
           overtimeSalary: OverTimeSetting(baseWorkHours: 8, overtimePayRate: 1400),
           lateSalary: LateSalary(
            lateSalary: 1400,
            startTime: Date(),
            endTime: Date()
           ),
           paymentType: .hourly
       )
   )
    
    
    var container: ModelContainer?

    
    init()async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Company.self, configurations: config)
    }
    
    
    @MainActor
    @Test
    func testAddAndFetchCompany() async throws {
        guard let container = container else {
            throw TestError.containerNotInitialized
        }
        let context = container.mainContext
        
        let repo = SwiftDataCompanyRepo(context: context)
        // Add a company
        await repo.addCompany(company)


        // Fetch companies
        let descriptor = FetchDescriptor<Company>()
        let results = try context.fetch(descriptor)
        #expect(results.count == 1)
        #expect(results.first?.name == "Test2Company")
    }

    @MainActor
    @Test
    func testUpdateCompany() async throws {
        guard let container = container else {
            throw TestError.containerNotInitialized
        }
        let context = container.mainContext
        
        let repo = SwiftDataCompanyRepo(context: context)


        // Add
        await repo.addCompany(company)

        // Update
        company.name = "New Name"
        try await repo.updateCompany(company)

        let descriptor = FetchDescriptor<Company>()
        let results = try context.fetch(descriptor)

        #expect(results.first?.name == "New Name")
    }

    @MainActor
    @Test
    func testDeleteCompany() async throws {
        guard let container = container else {
            throw TestError.containerNotInitialized
        }
        let context = container.mainContext
        
        let repo = SwiftDataCompanyRepo(context: context)

        // Add
        await repo.addCompany(company)

        // Delete
        try await repo.deleteCompany(company)

        let descriptor = FetchDescriptor<Company>()
        let results = try context.fetch(descriptor)

        #expect(results.isEmpty)
    }
}
