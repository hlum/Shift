//
//  PayDayUseCase.swift
//  Shift
//
//  Created by cmStudent on 2025/05/22.
//

import Foundation

class PayDayUseCase {
    private let holidayUseCase: HolidayUseCase
    
    init(holidayUseCase: HolidayUseCase) {
        self.holidayUseCase = holidayUseCase
    }
    
    func getSalaryDates(for shifts: [Shift]) async -> [Date] {
        var salaryDates: [Date] = []
        
        let shiftsWithDifferentMonths = self.getShiftsWithDifferentMonths(from: shifts)
        
        for shift in shiftsWithDifferentMonths {
            let holidayPayChange: Bool = shift.company.payDay.holidayPayDayChange
            let holidayPayEarly: Bool = shift.company.payDay.holidayPayEarly
            let payTiming = shift.company.payDay.payTiming
            let color: ColorName = shift.company.color
            
            let components = Calendar.current.dateComponents([.year,. month], from: shift.startTime)
            let workYear: Int = components.year ?? 0
            let workMonth: Int = components.month ?? 0
            let plainPayDay: Date = shift.company.payDay.payDay.payDate(forWorkMonth: workMonth, workYear: workYear, payTiming: payTiming)!
            
            let salaryDate = await self.getActualPayDay(holidayPayChange: holidayPayChange , holidayPayEarly: holidayPayEarly, plainPayDay: plainPayDay)
            salaryDates.append(salaryDate)
        }
        
        return salaryDates
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
        super.init(holidayUseCase: MockHolidayUseCase())
    }
    
    override func getSalaryDates(for shifts: [Shift]) async -> [Date] {
        return shifts.map { $0.startTime }
    }
}
