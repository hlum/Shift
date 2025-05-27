//
//  MockShiftRepository.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData

final class MockShiftRepository: ShiftRepository {
    var shifts: [Shift] = []
    
    init() {
        shifts = getMockShifts()
    }
    
    func getMockShifts() -> [Shift] {
        return [
            .init(
                name: "Test1",
                startTime: createDate(year: 2025, month: 5, day: 1, hour: 10, minute: 10),
                breakDuration: 10,
                endTime: Date(),
                company: Company(
                    
                    name: "Test2Company",
                    color: .blue,
                    endDate: .endOfMonth,
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
            ),
            .init(
                name: "Test2",
                startTime: createDate(year: 2025, month: 4, day: 5, hour: 10, minute: 10)
                , breakDuration: 1,
                endTime: Date(),
                company: Company(
                    name: "Test2Company",
                    color: .blue,
                    endDate: .day(10),
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
            )
        ]
    }
    
    private func createDate(year: Int = 2025, month: Int = 5, day: Int = 5, hour: Int = 10, minute: Int = 0) -> Date {
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }

    
    func fetchShifts(descriptor: FetchDescriptor<Shift>) throws -> [Shift] {
        return getMockShifts()
    }
    
    func addShift(_ shift: Shift) throws {
        shifts.append(shift)
    }
    
    func updateShift(_ shift: Shift) throws {
        guard let index = shifts.firstIndex(where: {shift.id == $0.id}) else { return }
        shifts[index] = shift
    }
    
    func deleteShift(_ shift: Shift) throws {
        guard let index = shifts.firstIndex(where: {shift.id == $0.id}) else { return }
        shifts.remove(at: index)
    }
    
    
}
