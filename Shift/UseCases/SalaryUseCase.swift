import Foundation

protocol SalaryUseCaseProtocol {
    func calculateMonthlySalary(for shifts: [Shift], countryCode: String) async throws -> Double
}

final class SalaryUseCase: SalaryUseCaseProtocol {
    private let holidayUseCase: HolidayUseCase
    private let salaryCalculator: SalaryCalculator
    
    init(holidayUseCase: HolidayUseCase, salaryCalculator: SalaryCalculator = SalaryCalculatorImpl()) {
        self.holidayUseCase = holidayUseCase
        self.salaryCalculator = salaryCalculator
    }
    
    func calculateMonthlySalary(for shifts: [Shift], countryCode: String) async throws -> Double {
        guard !shifts.isEmpty else { return 0 }
        
        return try await withThrowingTaskGroup(of: Double.self) { group in
            for shift in shifts {
                let company = shift.company
                let salary = company.salary
                
                let holidays = await holidayUseCase.fetchHolidaysAndWeekends(
                    between: DateInterval(start: shift.startTime, end: shift.endTime)
                )
                
                let segments = ShiftSplitter.shared.splitShiftByDay(
                    shiftStart: shift.startTime,
                    shiftEnd: shift.endTime,
                    holidays: holidays
                )
                
                for segment in segments {
                    group.addTask { @MainActor in
                        try await self.salaryCalculator.calculateOneSegmentSalary(
                            shiftName: shift.name,
                            shiftSegment: segment,
                            baseSalary: salary.baseSalary,
                            transportationExpense: salary.transportationExpense,
                            paymentType: salary.paymentType,
                            baseWorkHours: salary.overtimeSalary?.baseWorkHours,
                            overtimeSalary: salary.overtimeSalary?.overtimePayRate,
                            breakDuration: shift.breakDuration,
                            holidaySalary: salary.holidaySalary,
                            lateSalary: salary.lateSalary
                        )
                    }
                }
            }
            
            var total: Double = 0
            for try await salary in group {
                total += salary
            }
            return total
        }
    }
}

// MARK: - Mock Implementation
final class MockSalaryUseCase: SalaryUseCaseProtocol {
    func calculateMonthlySalary(for shifts: [Shift], countryCode: String) async throws -> Double {
        return 1000.0 // Mock value for testing
    }
} 
