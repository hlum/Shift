//
//  SalaryCalculator.swift
//  Shift
//
//  Created by cmStudent on 2025/05/13.
//

import Foundation

@MainActor
final class SalaryCalculator {
    private let debugShift: String = "Fa"
    
    func calculateOneSegmentSalary(
        shiftName: String = "Fa",
        shiftSegment: ShiftSegment,
        baseSalary: Int,
        transportationExpense: Int,
        paymentType: PaymentType,
        baseWorkHours: Double?,
        overtimeSalary: Int?,
        breakDuration: Double,
        holidaySalary: Int?,
        lateSalary: LateSalary?
    ) async throws -> Double {
        var totalSalary: Double = 0
        
        guard shiftSegment.start < shiftSegment.end else {
            return 0
        }
        
        var latePlusRate = 0.0
        if let lateRate = lateSalary?.lateSalary {
            latePlusRate = Double(lateRate - baseSalary)
        }
        
        var overtimePlusRate = 0.0
        if let overtimeRate = overtimeSalary {
            overtimePlusRate = Double(overtimeRate - baseSalary)
        }
        
        // Add transportation expense
        totalSalary += Double(transportationExpense)
        
        debug(for: shiftName, "transportation fees added TotalPay: \(totalSalary)")

        
        if paymentType == .oneDay {
            // For one-day payment type, just return base salary + transportation
            debug(for: shiftName, "OneDay payment TotalPay: \(totalSalary + Double(baseSalary))")

            return totalSalary + Double(baseSalary)

        }
        
        let roundedStartTime = roundToNearestMinute(shiftSegment.start)
        let roundedEndTime = roundToNearestMinute(shiftSegment.end)
        debug(for: shiftName, "startTimeRounded: \(roundedStartTime.formatted(.dateTime.day().hour().minute().second()))\n endTimeRounded: \(roundedEndTime.formatted(.dateTime.day().hour().minute().second()))")

        let hoursWorked = getHoursWorked(
            shiftName: shiftName,
            from: roundedStartTime,
            till: roundedEndTime,
            breakDuration: breakDuration
        )

        debug(for: shiftName, "isHoliday: \(shiftSegment.isHoliday)")
        
        let baseRate = holidaySalary != nil && shiftSegment.isHoliday ?
            Double(holidaySalary!) :
            Double(baseSalary)
        
        debug(for: shiftName, "baseRate: \(baseRate)")
        
        // Calculate base salary for hours worked
        totalSalary += baseRate * hoursWorked
        debug(for: shiftName, "totalSalary after baseRate: \(totalSalary)")

        // Handle overtime if applicable
        let overtimePay = calculateOvertimePay(
            shiftName: shiftName,
            hoursWorked: hoursWorked,
            overtimePlusRate: overtimePlusRate,
            baseWorkHours: baseWorkHours
            
        )
        debug(for: shiftName, "overtimePay: \(overtimePay)")

        totalSalary += overtimePay
        
        debug(for: shiftName, "totalSalary after overtimePay: \(totalSalary)")
        
        // Calculate late night salary
        let lateNightSalary = calculateLateNightBonus(
            shiftName: shiftName,
            shiftStart: roundedStartTime,
            shiftEnd: roundedEndTime,
            lateStart: lateSalary?.startTime,
            lateEnd: lateSalary?.endTime,
            latePlusRate: latePlusRate
        )
        debug(for: shiftName, "lateNightPay: \(lateNightSalary)")

        
        totalSalary += lateNightSalary
        debug(for: shiftName, "totalSalary after lateNightSalary: \(totalSalary)")

        
        return totalSalary
    }
    
    
    
    private func calculateOvertimePay(
        shiftName: String,
        hoursWorked: Double,
        overtimePlusRate: Double,
        baseWorkHours: Double?
    ) -> Double {
        
        if hoursWorked <= baseWorkHours ?? 0 { return 0.0 }
        
        let overtimeHours = hoursWorked - (baseWorkHours ?? 0)
        
        debug(for: shiftName, "OverTime Hours: \(overtimeHours)")
        return overtimePlusRate * overtimeHours
    }
    
    
    
    private func calculateLateNightBonus(
        shiftName: String,
        shiftStart: Date,
        shiftEnd: Date,
        lateStart: Date?,
        lateEnd: Date?,
        latePlusRate: Double
    ) -> Double {
        guard let lateStart,
              let lateEnd
        else { return 0.0 }
        
        debug(for: debugShift, "LateStart: \(lateStart.formatted())")
        debug(for: debugShift, "LateStart: \(lateEnd.formatted())")


        let lateStartTime = Time(date: lateStart)
        let lateEndTime = Time(date: lateEnd)
        
        debug(for: debugShift, "LateStart: \(lateStartTime.hour):\(lateStartTime.minute)")
        debug(for: debugShift, "LateStart: \(lateEndTime.hour):\(lateEndTime.minute)")

        let lateNightHours = calculateLateNightHours(
            shiftName: shiftName,
            shiftStart: shiftStart,
            shiftEnd: shiftEnd,
            lateStart: lateStartTime,
            lateEnd: lateEndTime
        )
        debug(for: debugShift, "Total LateNight Hours: \(lateNightHours)")
        return latePlusRate * lateNightHours
    }
    
    
    private func calculateLateNightHours(
        shiftName: String,
        shiftStart: Date,
        shiftEnd: Date,
        lateStart: Time,
        lateEnd: Time
    ) -> Double {
        let calendar = Calendar.current
        
        // Helper to create Date from Time and reference date
        func date(from time: Time, reference: Date) -> Date {
            var components = calendar.dateComponents([.year, .month, .day], from: reference)
            components.hour = time.hour
            components.minute = time.minute
            return calendar.date(from: components)!
        }
        
        // Create late night period dates
        let lateStartDate = date(from: lateStart, reference: shiftStart)
        let lateEndDate = date(from: lateEnd, reference: shiftStart)
        
        // If lateEnd is before or equal to lateStart, it means the period passes midnight
        let crossesMidnight = lateEnd.hour < lateStart.hour || (lateEnd.hour == lateStart.hour && lateEnd.minute <= lateStart.minute)
        
        if crossesMidnight {
            // For overnight shifts, we need to handle two cases:
            // 1. Shift starts before midnight and ends after midnight
            // 2. Shift starts after midnight
            
            // If shift starts after midnight, we only need to check overlap with the early morning part
            if calendar.component(.hour, from: shiftStart) >= 0 && calendar.component(.hour, from: shiftStart) < lateEnd.hour {
                let overlap = overlapDuration(start1: shiftStart, end1: shiftEnd, start2: date(from: Time(hour: 0, minute: 0), reference: shiftStart), end2: lateEndDate)
                return overlap / 3600.0
            }
            
            // If shift starts before midnight, we need to check both parts
            let nextDayOfShiftStart = calendar.date(byAdding: .day,value: 1, to: shiftStart)!
            let lateEndOfDay = calendar.date(bySettingHour: 00, minute: 00, second: 00, of: nextDayOfShiftStart)!
            let midnight = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: calendar.date(byAdding: .day, value: 1, to: shiftStart)!)!
            let lateStartNextDay = date(from: lateEnd, reference: calendar.date(byAdding: .day, value: 1, to: shiftStart)!)
            
            // Overlap 1: lateStartDate to lateEndOfDay
            let overlap1 = overlapDuration(start1: shiftStart, end1: shiftEnd, start2: lateStartDate, end2: lateEndOfDay)
            // Overlap 2: midnight to lateStartNextDay
            let overlap2 = overlapDuration(start1: shiftStart, end1: shiftEnd, start2: midnight, end2: lateStartNextDay)
            
            return (overlap1 + overlap2) / 3600.0
        } else {
            // Late period does not cross midnight
            let overlap = overlapDuration(start1: shiftStart, end1: shiftEnd, start2: lateStartDate, end2: lateEndDate)
            return overlap / 3600.0
        }
    }
    
    // Helper to calculate overlap duration in seconds between two intervals
    private func overlapDuration(start1: Date, end1: Date, start2: Date, end2: Date) -> TimeInterval {
        let start = max(start1, start2)
        let end = min(end1, end2)
        return max(0, end.timeIntervalSince(start))
    }
    
    
    /// Calculates the total hours worked between two times, subtracting break time.
    /// - Parameters:
    ///  - start: The starting time of the shift as a **rounded** `Date`.
    ///  - end: The ending time of the shift as a **rounded** `Date`.
    ///  - break: The break duration in **minutes** as a `Double`.
    private func getHoursWorked(
        shiftName: String,
        from start: Date,
        till end: Date,
        breakDuration: Double
    ) -> Double {
        let roundedStartTime = roundToNearestMinute(start)
        var roundedEndTime = roundToNearestMinute(end)
        
        // If end time is before start time, it means the shift crosses midnight
        if roundedEndTime < roundedStartTime {
            // Add 24 hours to end time
            roundedEndTime = Calendar.current.date(byAdding: .day, value: 1, to: roundedEndTime)!
        }
        
        let workedTimeSec = roundedEndTime.timeIntervalSince(roundedStartTime) - (breakDuration * 60)
        
        debug(for: shiftName, "break: \(breakDuration)")
        debug(for: shiftName, "HoursWorked with break: \(workedTimeSec / 3600)")

        return workedTimeSec / 3600
    }
    
    
    /// Round the sec
    private func roundToNearestMinute(_ date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.second = 0
        return calendar.date(from: components)!
    }
    
    
    private func debug(for shift: String, _ text: String) {
        if shift == self.debugShift {
            Logger.standard.info("\(text)")
        }
    }
}
