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
    @Test
    func testAddAndFetchCompany() async throws {
        let repo = try await getRepo()
        let context = try await testContainer().mainContext

        // Add a company
        await repo.addCompany(company)


        // Fetch companies
        let descriptor = FetchDescriptor<Company>()
        let results = try await context.fetch(descriptor)
        #expect(results.count == 1)
        #expect(results.first?.name == "Test2Company")
    }

    @Test
    func testUpdateCompany() async throws {
        let repo = try await getRepo()
        let context = try await testContainer().mainContext



        // Add
        await repo.addCompany(company)

        // Update
        company.name = "New Name"
        try await repo.updateCompany(company)

        let descriptor = FetchDescriptor<Company>()
        let results = try context.fetch(descriptor)

        #expect(results.first?.name == "New Name")
    }

    @Test
    func testDeleteCompany() async throws {
        let repo = try await getRepo()
        let context = try await testContainer().mainContext


        // Add
        await repo.addCompany(company)

        // Delete
        try await repo.deleteCompany(company)

        let descriptor = FetchDescriptor<Company>()
        let results = try context.fetch(descriptor)

        #expect(results.isEmpty)
    }

    func testContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: Company.self, configurations: config)
    }
    
    func getRepo() async throws -> SwiftDataCompanyRepo {
        let container = try testContainer()
        let context = await container.mainContext
        let repo = await SwiftDataCompanyRepo(context: context)
        return repo
    }
}
