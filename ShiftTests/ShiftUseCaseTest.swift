//
//  ShiftUseCaseTest.swift
//  ShiftTests
//
//  Created by cmStudent on 2025/05/23.
//

import Testing
import SwiftData
import Foundation
@testable import Shift

struct ShiftUseCaseTest {
    let mockShiftRepository = MockShiftRepository()
    var container: ModelContainer?
    
    init() async throws {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: Shift.self, configurations: config)
    }
    
    
    @MainActor
    @Test func addShiftsTest() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
        // given
        guard let container = container else {
            throw TestError.containerNotInitialized
        }
        
        let context = container.mainContext
        let repo = SwiftDataShiftRepo(context: context)
        let shiftUseCase = ShiftUseCase(shiftRepository: repo)
        let dummyCompany = getDummyCompany(settlementDate: .day(20))
        let dummyShifts: [Shift] = getDummyShifts(company: dummyCompany)
        
        for shift in dummyShifts {
            try await shiftUseCase.addShift(shift)
        }
        
        let fetchedShifts: [Shift] = try await shiftUseCase.fetchShifts(descriptor: nil)
        #expect(fetchedShifts.count == dummyShifts.count)
    }
    
    @MainActor
    @Test func lastMonthShiftsBeforeSettlementDateTest() async throws {
        
        
        guard let container = container else {
            throw TestError.containerNotInitialized
        }
        let context = container.mainContext
        let repo = SwiftDataShiftRepo(context: context)
        let shiftUseCase = ShiftUseCase(shiftRepository: repo)
        
        for _ in 1...100 {
            let randSettleMentDay = Int.random(in: 1...31)
            let dummyCompany = getDummyCompany(settlementDate: .day(randSettleMentDay))
            
            let randStartDayOfSecondShift = Int.random(in: 1...30)
            let dummyShifts: [Shift] = getDummyShifts(company: dummyCompany, secondShiftStartDay: randStartDayOfSecondShift)
            
            let shouldGetShiftCount: Int = randSettleMentDay >= randStartDayOfSecondShift ? 1 : 0
            
            for shift in dummyShifts {
                try await shiftUseCase.addShift(shift)
            }


            
            let shift = dummyShifts[0]
            
            
            
            let currentDate = createDate(year: 2025, month: 05, day: 20, hour: 20, minute: 20)
            
            let lastMonthShifts = try await shiftUseCase.getLastMonthShiftsBeforeSettlementDate(company: shift.company, currentDate: currentDate)
            let debugMessage = """
            Failed test:
              Settlement date: \(randSettleMentDay)
              ShiftStartTime: \(shift.startTime.formatted(.dateTime))
              SecondShiftStartTime: \(dummyShifts[1].startTime.formatted(.dateTime))
              randStartDayOfSecondShift: \(randStartDayOfSecondShift)
              expectedCount: \(shouldGetShiftCount)
              actualCount: \(lastMonthShifts.count)
            """

            #expect(lastMonthShifts.count == shouldGetShiftCount,"\(debugMessage)")
        }
    }
    
    
    private func getDummyCompany(settlementDate: SettlementDate) -> Company {
        let company = Company(
            
            name: "Test2Company",
            color: .blue,
            endDate: settlementDate,
            payDay: PayDay(
                payDay: .endOfMonth,
                payTiming: .currentMonth,
                holidayPayDayChange: false,
                holidayPayEarly: false
            ) ,
            salary: Salary(
                baseSalary: 1400,
                transportationExpense: 360,
                holidaySalary: 1400,
                lateSalary:LateSalary(
                    lateSalary: 1400,
                    startTime: Date(),
                    endTime: Date()
                   ),
                paymentType: .oneDay
            )
        )

        return company
    }
    
    private func getDummyShifts(company: Company, secondShiftStartDay: Int = 21) -> [Shift] {
       return [
        .init(
            name: "Test1",
            startTime: createDate(year: 2025, month: 5, day: 1, hour: 10, minute: 10),
            breakDuration: 10,
            endTime: Date(),
            company: company
        ),
        .init(
            name: "Test2",
            startTime: createDate(year: 2025, month: 4, day: secondShiftStartDay, hour: 0, minute: 0)
            , breakDuration: 1,
            endTime: Date(),
            company: company
        )
    ]
    }
    
    private func createDate(year: Int = 2025, month: Int = 5, day: Int = 5, hour: Int = 10, minute: Int = 0) -> Date {
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }


}
