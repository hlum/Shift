//
//  SalaryCalculatorTest.swift
//  ShiftTests
//
//  Created by cmStudent on 2025/05/16.
//

import Testing
import Foundation
@testable import Shift

@Suite("Salary Calculator Tests")
struct SalaryCalculatorTest {
    var salaryCalculator: SalaryCalculator
    
    init() async {
        salaryCalculator = await SalaryCalculator()
    }
    
    @Test("Normal time calculation")
    func normalTimeCalculation() async throws {
        // Given
        let startTime = createDate(day: 6, hour: 10)
        let endTime = createDate(day: 6, hour: 18)
        
        // When
        let salary = try await salaryCalculator.calculateTotalSalary(
            baseSalary: 1000,
            transportationExpense: 0,
            paymentType: .hourly,
            shiftStartTime: startTime,
            shiftEndTime: endTime,
            baseWorkHours: nil,
            overtimeSalary: nil,
            breakDuration: 0,
            holidaySalary: 1400,
            lateSalary: nil,
            isHoliday: false
        )
        
        // Then
        #expect(salary == 8000, "Salary should be 8000 for 8 hours of work")
    }
    
    @Test("Holiday time calculation")
    func holidayTimeCalculation() async throws {
        // Given
        let startTime = createDate(day: 6, hour: 10)
        let endTime = createDate(day: 6, hour: 18)
        
        // When
        let salary = try await salaryCalculator.calculateTotalSalary(
            baseSalary: 1000,
            transportationExpense: 0,
            paymentType: .hourly,
            shiftStartTime: startTime,
            shiftEndTime: endTime,
            baseWorkHours: nil,
            overtimeSalary: nil,
            breakDuration: 0,
            holidaySalary: 1400,
            lateSalary: nil,
            isHoliday: true
        )
        
        // Then
        #expect(salary == 11200, "Holiday salary should be 1.4 times the normal rate")
    }
    
    
    @Test("Holiday Late Night Calculation")
    func holidayLateNightCalculation() async throws {
        // Given
        let startTime = createDate(day: 6, hour: 20)
        let endTime = createDate(day: 7, hour: 8) // 20:00 ~ 8:00
        
        let lateStartTime = createDate(hour: 22)
        let lateEndTime = createDate(hour: 7) // 22:00 ~ 7:00
        
        let lateSalary = LateSalary(lateSalary: 1200, startTime: lateStartTime, endTime: lateEndTime)
        
        
        // When
        let salary = try await salaryCalculator.calculateTotalSalary(
            baseSalary: 1000,
            transportationExpense: 0,
            paymentType: .hourly,
            shiftStartTime: startTime,
            shiftEndTime: endTime,
            baseWorkHours: nil,
            overtimeSalary: nil,
            breakDuration: 0,
            holidaySalary: 1100,
            lateSalary: lateSalary,
            isHoliday: true
        )
        
        // Then
        #expect(salary == 15000, "Holiday salary should be 1.4 times the normal rate")
    }
    
    @Test("Overtime calculation")
    func overtimeCalculation() async throws {
        // Given
        let startTime = createDate(day: 6, hour: 10)
        let endTime = createDate(day: 6, hour: 20) // 10 hours total
        
        // When
        let salary = try await salaryCalculator.calculateTotalSalary(
            baseSalary: 1000,
            transportationExpense: 0,
            paymentType: .hourly,
            shiftStartTime: startTime,
            shiftEndTime: endTime,
            baseWorkHours: 8,
            overtimeSalary: 1500,
            breakDuration: 0,
            holidaySalary: 1400,
            lateSalary: nil,
            isHoliday: false
        )
        
        // Then
        #expect(salary == 11000, "Salary should include overtime pay")
    }
    
    
    @Test("Holiday Salary should be greater than normal pay")
    func holidaySalaryShouldBeGreaterThanNormalPay() async throws {
        for _ in 1...100 {
            // Given
            let startTime = createRandomDate()
            let endTime = createRandomDate()
            let baseSalary = randomSalary(range: 1000...1199)
            let holidaySalary = randomSalary(range: 1200...1600)
            
            // When
            let isHolidaySalary = try await salaryCalculator.calculateTotalSalary(
                baseSalary: baseSalary,
                transportationExpense: 0,
                paymentType: .hourly,
                shiftStartTime: startTime,
                shiftEndTime: endTime,
                baseWorkHours: nil,
                overtimeSalary: nil,
                breakDuration: 0,
                holidaySalary: holidaySalary,
                lateSalary: nil,
                isHoliday: true
            )
            
            let isNotHolidaySalary = try await salaryCalculator.calculateTotalSalary(
                baseSalary: baseSalary,
                transportationExpense: 0,
                paymentType: .hourly,
                shiftStartTime: startTime,
                shiftEndTime: endTime,
                baseWorkHours: nil,
                overtimeSalary: nil,
                breakDuration: 0,
                holidaySalary: holidaySalary,
                lateSalary: nil,
                isHoliday: false
            )
            
            // Then
            #expect(isHolidaySalary >= isNotHolidaySalary)
            
        }
    }
    
    @Test("Randomized time calculation")
    func randomizedTimeCalculation() async throws {
        for _ in 1...100 {
            // Given
            let startTime = createRandomDate()
            let endTime = createRandomDate()
            let baseSalary = randomSalary()
            let holidaySalary = randomSalary(range: 1200...1600)
            let isHoliday = Bool.random()
            
            // When
            let salary = try await salaryCalculator.calculateTotalSalary(
                baseSalary: baseSalary,
                transportationExpense: 0,
                paymentType: .hourly,
                shiftStartTime: startTime,
                shiftEndTime: endTime,
                baseWorkHours: nil,
                overtimeSalary: nil,
                breakDuration: 0,
                holidaySalary: holidaySalary,
                lateSalary: nil,
                isHoliday: isHoliday
            )
            
            // Then
            print("Random test: \(startTime) ~ \(endTime), base: \(baseSalary), holiday: \(holidaySalary), isHoliday: \(isHoliday), salary: \(salary)")
            #expect(salary >= 0, "Salary should not be negative")
        }
    }
    
    @Test("Randomized time calculation")
    func salaryShouldEqualOrGreaterThanBaseSalary() async throws {
        for _ in 1...100 {
            // Given
            let randomHour = Int.random(in: 8...18)
            print(randomHour)
            let (startTime, endTime) = createRandomStartAndEndDate(workHour: randomHour)
            let baseSalary = randomSalary(range: 1000...1199)
            let holidaySalary = randomSalary(range: 1200...1600)
            let isHoliday = Bool.random()
            
            // When
            let salary = try await salaryCalculator.calculateTotalSalary(
                baseSalary: baseSalary,
                transportationExpense: 0,
                paymentType: .hourly,
                shiftStartTime: startTime,
                shiftEndTime: endTime,
                baseWorkHours: nil,
                overtimeSalary: nil,
                breakDuration: 0,
                holidaySalary: holidaySalary,
                lateSalary: nil,
                isHoliday: isHoliday
            )
            

            // Then
            var expectedMinSalary = isHoliday ? Double(holidaySalary * randomHour) : Double(baseSalary * randomHour)
            
            print("Random test: \(startTime) ~ \(endTime), workHour: \(randomHour), base: \(baseSalary), holiday: \(holidaySalary), isHoliday: \(isHoliday), salary: \(salary)")
            
            #expect(salary >= expectedMinSalary, "Salary should be greater than or equal to base salary")
        }
    }

    
    // Helper function to create test dates
    private func createDate(year: Int = 2025, month: Int = 5, day: Int = 5, hour: Int = 10, minute: Int = 0) -> Date {
        return Calendar.current.date(from: DateComponents(year: year, month: month, day: day, hour: hour, minute: minute))!
    }
    
    private func randomHour(range: ClosedRange<Int> = 0...23) -> Int {
        return Int.random(in: range)
    }

    private func randomDay(range: ClosedRange<Int> = 1...28) -> Int {
        return Int.random(in: range)
    }
    
    private func createRandomStartAndEndDate(workHour: Int) -> (Date, Date) {
        let day = randomDay()
        let hour = randomHour()
        let startDate = createDate(day: day, hour: hour)
        let endDate = Calendar.current.date(byAdding: .hour, value: workHour, to: startDate)!
        return (startDate, endDate)
    }

    private func createRandomDate() -> Date {
        let day = randomDay()
        let hour = randomHour()
        return createDate(day: day, hour: hour)
    }

    private func randomSalary(range: ClosedRange<Int> = 900...2000) -> Int {
        return Int.random(in: range)
    }

}
