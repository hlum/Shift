//
//  MockShiftRepository.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData

final class MockShiftRepository: ShiftRepository {
    var shifts: [Shift] = [
        .init(
            id: UUID().uuidString,
            name: "Test1",
            startTime: Date(),
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
            id: UUID().uuidString,
            name: "Test2",
            startTime: Date(),
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
    
    func fetchShifts(descriptor: FetchDescriptor<Shift>) throws -> [Shift] {
        return shifts
    }
    
    func addShift(_ shift: Shift) {
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
