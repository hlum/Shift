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
        let shiftSegment = ShiftSplitter.shared.splitShiftByDay(shiftStart: startTime, shiftEnd: endTime, holidays: [])
        
        // When
        var total = 0.0
        for segment in shiftSegment {
            let salary = try await salaryCalculator.calculateOneSegmentSalary(
                shiftSegment: segment,
                baseSalary: 1000,
                transportationExpense: 0,
                paymentType: .hourly,
                baseWorkHours: nil,
                overtimeSalary: nil,
                breakDuration: 0,
                holidaySalary: 1400,
                lateSalary: nil
            )
            total += salary
        }
        // Then
        #expect(total == 8000, "Salary should be 8000 for 8 hours of work")
    }
    
    @Test("Holiday time calculation")
    func holidayTimeCalculation() async throws {
        // Given
        let startTime = createDate(day: 6, hour: 10)
        let endTime = createDate(day: 6, hour: 18)
        let shiftSegment = ShiftSplitter.shared.splitShiftByDay(shiftStart: startTime, shiftEnd: endTime, holidays: [startTime])
        
        // When
        var total = 0.0
        for segment in shiftSegment {
            let salary = try await salaryCalculator.calculateOneSegmentSalary(
                shiftSegment: segment,
                baseSalary: 1000,
                transportationExpense: 0,
                paymentType: .hourly,
                baseWorkHours: nil,
                overtimeSalary: nil,
                breakDuration: 0,
                holidaySalary: 1400,
                lateSalary: nil
            )
            total += salary
        }
        
        // Then
        #expect(total == 11200, "Holiday salary should be 1.4 times the normal rate")
    }
    
    
    @Test("Holiday Late Night Calculation")
    func holidayLateNightCalculation() async throws {
        // Given
        // Shift start at 20:00~8:00 12hr
        // 20:00~midnight = 4000 + late 400 = 4400
        // 00:00 ~ 8:00 = 11200(holiday) + late 1400 = 12600
        // nextDay is holiday
        // lateTime 22:00~7:00
        let startTime = createDate(day: 6, hour: 20)
        let endTime = createDate(day: 7, hour: 8) // 20:00 ~ 8:00
        let shiftSegment = ShiftSplitter.shared.splitShiftByDay(shiftStart: startTime, shiftEnd: endTime, holidays: [endTime])
        
        let lateStartTime = createDate(hour: 22)
        let lateEndTime = createDate(hour: 7) // 22:00 ~ 7:00
        
        let lateSalary = LateSalary(lateSalary: 1200, startTime: lateStartTime, endTime: lateEndTime)
        
        
        // When
        var total = 0.0
        for segment in shiftSegment {
            let salary = try await salaryCalculator.calculateOneSegmentSalary(
                shiftSegment: segment,
                baseSalary: 1000,
                transportationExpense: 0,
                paymentType: .hourly,
                baseWorkHours: nil,
                overtimeSalary: nil,
                breakDuration: 0,
                holidaySalary: 1400,
                lateSalary: lateSalary
            )
            total += salary
        }
        
        // Then
        #expect(total == 17000)
    }
    
    @Test("Overtime calculation")
    func overtimeCalculation() async throws {
        // Given
        let startTime = createDate(day: 6, hour: 10)
        let endTime = createDate(day: 6, hour: 20) // 10 hours total
        let shiftSegment = ShiftSplitter.shared.splitShiftByDay(shiftStart: startTime, shiftEnd: endTime, holidays: [])

        // When
        var total = 0.0
        for segment in shiftSegment {
            let salary = try await salaryCalculator.calculateOneSegmentSalary(
                shiftSegment: segment,
                baseSalary: 1000,
                transportationExpense: 0,
                paymentType: .hourly,
                baseWorkHours: 8,
                overtimeSalary: 1500,
                breakDuration: 0,
                holidaySalary: 1400,
                lateSalary: nil
            )
            total += salary
        }
        
        
        // Then
        #expect(total == 11000, "Salary should include overtime pay")
    }

    
    @Test("Randomized time calculation")
    func randomizedTimeCalculation() async throws {
        for _ in 1...10 {
            // Given
            let startTime = createRandomDate()
            let endTime = createRandomDate()
            
            let baseSalary = randomSalary()
            let holidaySalary = randomSalary(range: 1200...1600)
            let isHoliday = Bool.random()
            var holiday:[Date] = []
            if isHoliday {
                holiday.append(startTime)
            }
            let shiftSegments = ShiftSplitter.shared.splitShiftByDay(shiftStart: startTime, shiftEnd: endTime, holidays: holiday)

            
            
            // When
            var total = 0.0
            for segment in shiftSegments {
                let salary = try await salaryCalculator.calculateOneSegmentSalary(
                    shiftSegment: segment,
                    baseSalary: baseSalary,
                    transportationExpense: 0,
                    paymentType: .hourly,
                    baseWorkHours: nil,
                    overtimeSalary: nil,
                    breakDuration: 0,
                    holidaySalary: holidaySalary,
                    lateSalary: nil
                )
                total += salary
            }
            
            // Then
            print("Random test: \(startTime) ~ \(endTime), base: \(baseSalary), holiday: \(holidaySalary), isHoliday: \(isHoliday), salary: \(total)")
            #expect(total >= 0, "Salary should not be negative")
        }
    }
    
    @Test("Randomized time calculation")
    func salaryShouldEqualOrGreaterThanBaseSalary() async throws {
        for _ in 1...10 {
            // Given

            let randomHour = Int.random(in: 8...100000)
            print(randomHour)
            let (startTime, endTime) = createRandomStartAndEndDate(workHour: randomHour)
            let baseSalary = randomSalary(range: 1000...1199)
            let holidaySalary = randomSalary(range: 1200...1600)
            let isHoliday = Bool.random()
            var holiday:[Date] = []
            if isHoliday {
                holiday.append(startTime)
            }
            let shiftSegments = ShiftSplitter.shared.splitShiftByDay(shiftStart: startTime, shiftEnd: endTime, holidays: holiday)

            
            // When
            var total = 0.0
            for segment in shiftSegments {
                let salary = try await salaryCalculator.calculateOneSegmentSalary(
                    shiftSegment: segment,
                    baseSalary: baseSalary,
                    transportationExpense: 0,
                    paymentType: .hourly,
                    baseWorkHours: nil,
                    overtimeSalary: nil,
                    breakDuration: 0,
                    holidaySalary: holidaySalary,
                    lateSalary: nil
                )
                total += salary
            }
            

            // Then
            var expectedMinSalary = Double(baseSalary * randomHour)
            
            print("Random test: \(startTime) ~ \(endTime), workHour: \(randomHour), base: \(baseSalary), holiday: \(holidaySalary), isHoliday: \(isHoliday), salary: \(total), expectedMinSalary: \(expectedMinSalary)")
            
            #expect(total >= expectedMinSalary, "Salary should be greater than or equal to \(expectedMinSalary)")
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
