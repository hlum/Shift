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
    
    
    
    func calculateTotalSalary(
        shiftName: String = "Fa",
        baseSalary: Int,
        transportationExpense: Int,
        paymentType: PaymentType,
        shiftStartTime: Date,
        shiftEndTime: Date,
        baseWorkHours: Double?,
        overtimeSalary: Int?,
        breakDuration: Double,
        holidaySalary: Int?,
        lateSalary: LateSalary?,
        isHoliday: Bool
    ) async throws -> Double {
        var totalSalary: Double = 0
        
        guard shiftStartTime < shiftEndTime else {
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
        
        let roundedStartTime = roundToNearestMinute(shiftStartTime)
        let roundedEndTime = roundToNearestMinute(shiftEndTime)
        debug(for: shiftName, "startTimeRounded: \(roundedStartTime.formatted(.dateTime.day().hour().minute().second()))\n endTimeRounded: \(roundedEndTime.formatted(.dateTime.day().hour().minute().second()))")

        let hoursWorked = getHoursWorked(
            shiftName: shiftName,
            from: roundedStartTime,
            till: roundedEndTime,
            breakDuration: breakDuration
        )

        debug(for: shiftName, "isHoliday: \(isHoliday)")
        
        let baseRate = holidaySalary != nil && isHoliday ?
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
        
        let lateStartTime = Time(date: lateStart)
        let lateEndTime = Time(date: lateEnd)
        
        let lateNightHours = calculateLateNightHours(
            shiftName: shiftName,
            shiftStart: shiftStart,
            shiftEnd: shiftEnd,
            lateStart: lateStartTime,
            lateEnd: lateEndTime
        )
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
        
        // Convert late night period to Date
        func createLatePeriod(for date: Date) -> (start: Date, end: Date) {
            var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
            startComponents.hour = lateStart.hour
            startComponents.minute = lateStart.minute
            let startDate = calendar.date(from: startComponents)!
            
            var endComponents = startComponents
            endComponents.hour = lateEnd.hour
            endComponents.minute = lateEnd.minute
            
            // If late night period crosses midnight, add one day
            if lateEnd.hour < lateStart.hour || (lateEnd.hour == lateStart.hour && lateEnd.minute < lateStart.minute) {
                endComponents.day! += 1
            }
            let endDate = calendar.date(from: endComponents)!
            
            return (startDate, endDate)
        }
        
        var totalLateHours: Double = 0.0
        var currentDate = calendar.startOfDay(for: shiftStart)
        
        // Loop until we reach the end of the shift
        while currentDate < shiftEnd {
            let (lateStartDate, lateEndDate) = createLatePeriod(for: currentDate)
            
            // Calculate overlap between shift and late night period
            let overlapStart = max(shiftStart, lateStartDate)
            let overlapEnd = min(shiftEnd, lateEndDate)
            
            if overlapEnd > overlapStart {
                let seconds = overlapEnd.timeIntervalSince(overlapStart)
                totalLateHours += seconds / 3600.0
            }
            
            // Move to next day
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        debug(for: shiftName, "Total LateHours: \(totalLateHours)h")
        return totalLateHours
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
