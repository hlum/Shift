//
//  PayDayUseCase.swift
//  Shift
//
//  Created by cmStudent on 2025/05/22.
//

import Foundation
import SwiftData

/// Represents a salary payment day with associated company and amount
struct SalaryDay: Identifiable {
    let id: String = UUID().uuidString
    let date: Date
    let company: Company
    let amount: Double
}

protocol SalaryDayUseCaseProtocol {
    func getSalaryDays(for shifts: [Shift]) async throws -> [SalaryDay]
}

class SalaryDayUseCase: SalaryDayUseCaseProtocol {
    private let holidayUseCase: HolidayUseCaseProtocol
    private let salaryUseCase: SalaryUseCaseProtocol
    private let shiftUseCase: ShiftUseCaseProtocol
    
    private let countryCode = Locale.current.region?.identifier ?? "JP"
    
    init(holidayUseCase: HolidayUseCaseProtocol, salaryUseCase: SalaryUseCaseProtocol, shiftUseCase: ShiftUseCaseProtocol) {
        self.holidayUseCase = holidayUseCase
        self.salaryUseCase = salaryUseCase
        self.shiftUseCase = shiftUseCase
    }
    
    
    /// Calculates the total hours worked between two times, subtracting break time.
    /// - Parameters shifts: all shifts.
    ///  - Returns: An array of **SalaryDay**
    func getSalaryDays(for shifts: [Shift]) async throws -> [SalaryDay] {
        let shifts = shiftUseCase.getShiftsWithDifferentSettlementPeriodsAndCompany(from: shifts)

        var salaryDays: [SalaryDay] = []
        
        for shift in shifts {
            let salaryDate = await getSalaryDate(shift: shift)
            let lastMonthShifts = try await shiftUseCase.getShiftsBetweenLastMonthSettlementPeriod(company: shift.company, currentDate: salaryDate)

            
            let salary = try await salaryUseCase.calculateMonthlySalary(for: lastMonthShifts, countryCode: countryCode)
            
            let salaryDay = SalaryDay(
                date: salaryDate,
                company: shift.company,
                amount: salary
            )
            salaryDays.append(salaryDay)
        }
        
        return salaryDays
    }
}



extension SalaryDayUseCase {
    /// - Returns: The date when the salary of the shift passed is paid
    private func getSalaryDate(shift: Shift) async -> Date {
        let comp = Calendar.current.dateComponents([.year, .month], from: shift.startTime)
        let workYear: Int = comp.year ?? 0
        let workMonth: Int = comp.month ?? 0
        
        let settlementPeriod = shift.company.settleMentDate.settlementPeriod(forMonth: comp.month!, year: comp.year!)
        let shiftIsInSettlementPeriod: Bool = shift.startTime >= settlementPeriod.start && shift.startTime <= settlementPeriod.end
        
        let holidayPayChange: Bool = shift.company.payDay.holidayPayDayChange
        let holidayPayEarly: Bool = shift.company.payDay.holidayPayEarly
        let payTiming = shift.company.payDay.payTiming
        

        let plainSalaryDayBeforeHolidayCheck: Date = shift.company.payDay.payDay.payDate(forWorkMonth: workMonth, workYear: workYear, payTiming: payTiming)!
        
        var salaryDayAfterHolidayCheck = await self.checkHolidayAndMoveSalaryDay(holidayPayChange: holidayPayChange , holidayPayEarly: holidayPayEarly, plainSalaryDay: plainSalaryDayBeforeHolidayCheck)
        
        // Move the payDay to next month if the shift start time isn't in the current month settlement period
        if !shiftIsInSettlementPeriod {
            salaryDayAfterHolidayCheck = Calendar.current.date(byAdding: .month, value: 1, to: salaryDayAfterHolidayCheck)!
        }
        return salaryDayAfterHolidayCheck
    }
    
    
    
    private func checkHolidayAndMoveSalaryDay(
        holidayPayChange: Bool,
        holidayPayEarly: Bool,
        plainSalaryDay: Date
    ) async -> Date {
        guard holidayPayChange else {
            // if holidayPayChange is false then the date won't change
            return plainSalaryDay
        }
        
        if holidayPayEarly {
            let earliestDateBeforeHoliday = await holidayUseCase.getDateBeforeHoliday(plainSalaryDay)
            print("Return early date: \(earliestDateBeforeHoliday.formatted(.dateTime.month().day()))")
            return earliestDateBeforeHoliday
        } else {
            let earliestDateAfterHoliday = await holidayUseCase.getDateAfterHoliday(plainSalaryDay)
            return earliestDateAfterHoliday
        }
    }
}

class MockPayDayUseCase: SalaryDayUseCase {
    init() {
        super.init(holidayUseCase: MockHolidayUseCase(), salaryUseCase: MockSalaryUseCase(), shiftUseCase: MockShiftUseCase())
    }
    
    override
    func getSalaryDays(for shifts: [Shift]) async throws -> [SalaryDay] {
        return []
    }
}
