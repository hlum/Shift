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
                id: "test2",
                name: "Test2Company",
                color: "Black",
                endDate: Date(),
                payDay: PayDay(
                    payDay: Date().addingTimeInterval(
                        86400
                    ),
                    holidayPayDayChange: false,
                    holidayPayEarly: false
                ) ,
                salary: Salary(
                    baseSalary: 1400,
                    transportationExpense: 360,
                    holidaySalary: 1400,
                    lateSalary: LateSalary(
                        salary: 1560,
                        startTime: Date(),
                        endTime: Date()
                    ),
                    overtimeSalary: 1560
                )
            )
        ),
        .init(
            id: UUID().uuidString,
            name: "Test2",
            startTime: Date(),
            endTime: Date(),
            company: Company(
                id: "test2",
                name: "Test2Company",
                color: "Black",
                endDate: Date(),
                payDay: PayDay(
                    payDay: Date().addingTimeInterval(
                        86400
                    ),
                    holidayPayDayChange: false,
                    holidayPayEarly: false
                ) ,
                salary: Salary(
                    baseSalary: 1400,
                    transportationExpense: 360,
                    holidaySalary: 1400,
                    lateSalary: LateSalary(
                        salary: 1560,
                        startTime: Date(),
                        endTime: Date()
                    ),
                    overtimeSalary: 1560
                )
            )
        )
    ]
    
    func fetchShifts(descriptor: FetchDescriptor<Shift>) throws -> [Shift] {
        return shifts
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
