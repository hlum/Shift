//
//  SalaryCalculator.swift
//  Shift
//
//  Created by cmStudent on 2025/05/13.
//

import Foundation

@MainActor
final class SalaryCalculator {
    private let company: Company
    private let shift: Shift
    private let holidayUseCase: HolidayUseCase
    private let countryCode: String
    
    private let debugShift: String = "Fa"
    
    
    
    init(company: Company, shift: Shift, holidayUseCase: HolidayUseCase, countryCode: String) {
        self.company = company
        self.shift = shift
        self.holidayUseCase = holidayUseCase
        self.countryCode = countryCode
    }
    
    
    
    func calculateTotalSalary() async throws -> Double {
        var totalSalary: Double = 0
        
        // Add transportation expense
        totalSalary += Double(company.salary.transportationExpense)
        
        debug(for: debugShift, "transportation fees added TotalPay: \(totalSalary)")

        
        if company.salary.paymentType == .oneDay {
            // For one-day payment type, just return base salary + transportation
            debug(for: debugShift, "OneDay payment TotalPay: \(totalSalary + Double(company.salary.baseSalary))")

            return totalSalary + Double(company.salary.baseSalary)

        }
        
        let roundedStartTime = roundToNearestMinute(shift.startTime)
        let roundedEndTime = roundToNearestMinute(shift.endTime)
        debug(for: debugShift, "startTimeRounded: \(roundedStartTime.formatted(.dateTime.day().hour().minute().second()))\n endTimeRounded: \(roundedEndTime.formatted(.dateTime.day().hour().minute().second()))")

        let hoursWorked = getHoursWorked(from: roundedStartTime, till: roundedEndTime, breakDuration: shift.breakDuration)

        
        // Determine base rate - use holiday salary if available
        let companyHasHolidaySalary = company.salary.holidaySalary != nil
        
        // Check if the shift date is a holiday
        let holidays = await holidayUseCase.fetchHoliday(for: roundedStartTime)
        let isHoliday = !holidays.isEmpty && holidayUseCase.isWeekend(roundedStartTime)
        
        debug(for: debugShift, "isHoliday: \(isHoliday)")
        
        let baseRate = companyHasHolidaySalary && isHoliday ?
            Double(company.salary.holidaySalary!) :
            Double(company.salary.baseSalary)
        
        debug(for: debugShift, "baseRate: \(baseRate)")
        
        // Calculate base salary for hours worked
        totalSalary += baseRate * hoursWorked
        debug(for: debugShift, "totalSalary after baseRate: \(totalSalary)")

        // Handle overtime if applicable
        let overtimePay = calculateOvertimePay(hoursWorked: hoursWorked, baseRate: baseRate)
        debug(for: debugShift, "overtimePay: \(overtimePay)")

        totalSalary += overtimePay
        
        debug(for: debugShift, "totalSalary after overtimePay: \(totalSalary)")
        
        // Calculate late night salary
        let lateNightSalary = calculateLateNightBonus(
            shiftStart: roundedStartTime,
            shiftEnd: roundedEndTime,
            baseRate: baseRate
        )
        debug(for: debugShift, "lateNightPay: \(lateNightSalary)")

        
        totalSalary += lateNightSalary
        debug(for: debugShift, "totalSalary after lateNightSalary: \(totalSalary)")

        
        return totalSalary
    }
    
    
    
    private func calculateOvertimePay(hoursWorked: Double, baseRate: Double) -> Double {
        guard let overtimeRate = company.salary.overtimeSalary else { return 0.0 }
        
        if hoursWorked <= overtimeRate.baseWorkHours { return 0.0 }
        
        let overtimeHours = hoursWorked - overtimeRate.baseWorkHours
        let overtimePayRate = Double(overtimeRate.overtimePayRate) - baseRate
        debug(for: debugShift, "OverTime Hours: \(overtimeHours)")
        return overtimePayRate * overtimeHours
    }
    
    
    
    private func calculateLateNightBonus(shiftStart: Date, shiftEnd: Date, baseRate: Double) -> Double {
        guard let lateSalary = company.salary.lateSalary,
              let lateAmount = lateSalary.lateSalary,
              let lateStart = lateSalary.startTime,
              let lateEnd = lateSalary.endTime else {
            return 0
        }
        
        let lateStartTime = Time(date: lateStart)
        let lateEndTime = Time(date: lateEnd)
        
        let lateNightHours = calculateLateNightHours(
            shiftStart: shiftStart,
            shiftEnd: shiftEnd,
            lateStart: lateStartTime,
            lateEnd: lateEndTime
        )
        
        let lateNightRate = Double(lateAmount) - baseRate

        return Double(lateNightRate) * lateNightHours
    }
    
    
    
    private func calculateLateNightHours(shiftStart: Date, shiftEnd: Date, lateStart: Time, lateEnd: Time) -> Double {
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
        debug(for: debugShift, "Total LateHours: \(totalLateHours)h")
        return totalLateHours
    }
    
    
    
    /// Calculates the total hours worked between two times, subtracting break time.
    /// - Parameters:
    ///  - start: The starting time of the shift as a **rounded** `Date`.
    ///  - end: The ending time of the shift as a **rounded** `Date`.
    ///  - break: The break duration in **minutes** as a `Double`.
    private func getHoursWorked(from start: Date, till end: Date, breakDuration: Double) -> Double {
        let roundedStartTime = roundToNearestMinute(start)
        var roundedEndTime = roundToNearestMinute(end)
        
        // If end time is before start time, it means the shift crosses midnight
        if roundedEndTime < roundedStartTime {
            // Add 24 hours to end time
            roundedEndTime = Calendar.current.date(byAdding: .day, value: 1, to: roundedEndTime)!
        }
        
        let workedTimeSec = roundedEndTime.timeIntervalSince(roundedStartTime) - (breakDuration * 60)
        
        debug(for: debugShift, "break: \(breakDuration)")
        debug(for: debugShift, "HoursWorked with break: \(workedTimeSec / 3600)")

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
        if shift == self.shift.name {
            Logger.standard.info("\(text)")
        }
    }
}
