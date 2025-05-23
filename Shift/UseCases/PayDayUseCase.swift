//
//  PayDayUseCase.swift
//  Shift
//
//  Created by cmStudent on 2025/05/22.
//

import Foundation

/// Represents a salary payment day with associated company and amount
struct SalaryDay: Identifiable {
    let id: String = UUID().uuidString
    let date: Date
    let company: Company
    let amount: Double
}

protocol PayDayUseCaseProtocol {
    func getSalaryDays(differentMonthAndCompanyShifts shifts: [Shift]) async throws -> [SalaryDay]
}

class PayDayUseCase: PayDayUseCaseProtocol {
    private let holidayUseCase: HolidayUseCaseProtocol
    private let salaryUseCase: SalaryUseCaseProtocol
    private let shiftUseCase: ShiftUseCaseProtocol
    
    init(holidayUseCase: HolidayUseCaseProtocol, salaryUseCase: SalaryUseCaseProtocol, shiftUseCase: ShiftUseCaseProtocol) {
        self.holidayUseCase = holidayUseCase
        self.salaryUseCase = salaryUseCase
        self.shiftUseCase = shiftUseCase
    }
    
    func getSalaryDays(differentMonthAndCompanyShifts shifts: [Shift]) async throws -> [SalaryDay] {
        var salaryDays: [SalaryDay] = []
        
        for shift in shifts {
            let salaryDate = await getSalaryDate(shift: shift)
            let lastMonthShifts = try await shiftUseCase.getLastMonthShiftsBeforeSettlementDate(company: shift.company, currentDate: salaryDate)
            let salary = try await salaryUseCase.calculateMonthlySalary(for: lastMonthShifts, countryCode: "US")
            
            let salaryDay = SalaryDay(
                date: salaryDate,
                company: shift.company,
                amount: salary
            )
            salaryDays.append(salaryDay)
        }
        
        return salaryDays
    }
    
    
    
    private func getSalaryDate(shift: Shift) async -> Date {
        let holidayPayChange: Bool = shift.company.payDay.holidayPayDayChange
        let holidayPayEarly: Bool = shift.company.payDay.holidayPayEarly
        let payTiming = shift.company.payDay.payTiming
        let color: ColorName = shift.company.color
        
        let components = Calendar.current.dateComponents([.year, .month], from: shift.startTime)
        let workYear: Int = components.year ?? 0
        let workMonth: Int = components.month ?? 0
        let plainPayDay: Date = shift.company.payDay.payDay.payDate(forWorkMonth: workMonth, workYear: workYear, payTiming: payTiming)!
        
        let salaryDate = await self.getActualPayDay(holidayPayChange: holidayPayChange , holidayPayEarly: holidayPayEarly, plainPayDay: plainPayDay)
        return salaryDate
    }
    
    
    
    private func getActualPayDay(
        holidayPayChange: Bool,
        holidayPayEarly: Bool,
        plainPayDay: Date
    ) async -> Date {
        guard holidayPayChange else {
            // if holidayPayChange is false then the date won't change
            return plainPayDay
        }
        
        if holidayPayEarly {
            let earliestDateBeforeHoliday = await holidayUseCase.getDateBeforeHoliday(plainPayDay)
            print("Return early date: \(earliestDateBeforeHoliday.formatted(.dateTime.month().day()))")
            return earliestDateBeforeHoliday
        } else {
            let earliestDateAfterHoliday = await holidayUseCase.getDateAfterHoliday(plainPayDay)
            return earliestDateAfterHoliday
        }
        
        
    }
    
    private func getShiftsWithDifferentMonths(from shifts: [Shift]) -> [Shift] {
        guard !shifts.isEmpty else {
            Logger.standard.warning("There is no shifts")
            return []
        }
        var seenMonthsCompany = Set<String>()

        var result: [Shift] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM" // Use year and month to handle multiple years

        for shift in shifts {
            let monthKey = formatter.string(from: shift.startTime)
            let companyName = shift.company.name
            let monthKeyCompany = "\(companyName)-\(monthKey)"
            
            
            if !seenMonthsCompany.contains(monthKeyCompany) {
                seenMonthsCompany.insert(monthKeyCompany)
                result.append(shift)
            }
        }
        return result
    }
}

class MockPayDayUseCase: PayDayUseCase {
    init() {
        super.init(holidayUseCase: MockHolidayUseCase(), salaryUseCase: MockSalaryUseCase(), shiftUseCase: MockShiftUseCase())
    }
    
    override
    func getSalaryDays(differentMonthAndCompanyShifts shifts: [Shift]) async throws -> [SalaryDay] {
        return []
    }
}
