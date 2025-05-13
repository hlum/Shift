//
//  Item.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData

@Model
final class Shift {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var startTime: Date
    var breakDuration: Double
    var endTime: Date
    
    @Relationship
    var company: Company
    
    init(name: String, startTime: Date, breakDuration: Double, endTime: Date, company: Company) {
        self.name = name
        self.startTime = startTime
        self.breakDuration = breakDuration
        self.endTime = endTime
        self.company = company
    }
}

struct Time {
    let hour: Int
    let minute: Int
    
    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }
    
    init(date: Date) {
        let calendar = Calendar.current
        self.hour = calendar.component(.hour, from: date)
        self.minute = calendar.component(.minute, from: date)
    }
    
    var minutesSinceMidnight: Int {
        return hour * 60 + minute
    }
}

extension Shift {
    
    var salary: Double {
        let debugShift = "Fa"
        // Calculate the Salary based on the company rules
        var totalSalary: Double = 0
        
        // Add transportation expense
        totalSalary += Double(company.salary.transportationExpense)
        debug(for: debugShift, "After Adding Transportation Expense: \(totalSalary)")
        
        if company.salary.paymentType == .oneDay {
            debug(for: debugShift, "One day payment type: \(totalSalary + Double(company.salary.baseSalary))")
            
            // For one-day payment type, just return base salary + transportation
            return totalSalary + Double(company.salary.baseSalary)
        }
        
        // For hourly payment type
        let roundedStartTime = roundToNearestMinute(startTime)
        var roundedEndTime = roundToNearestMinute(endTime)
        
        // If end time is before start time, it means the shift crosses midnight
        if roundedEndTime < roundedStartTime {
            // Add 24 hours to end time
            roundedEndTime = Calendar.current.date(byAdding: .day, value: 1, to: roundedEndTime)!
        }
        
        let workedTime = roundedEndTime.timeIntervalSince(roundedStartTime) - (breakDuration * 60)
        let hoursWorked = workedTime / 3600 // Convert seconds to hours
        debug(for: debugShift, "startTime: \(roundedStartTime.formatted(date: .abbreviated , time: .shortened))")
        debug(for: debugShift, "endTime: \(roundedEndTime.formatted(date: .abbreviated, time: .shortened))")
        
        debug(for: debugShift, "break: \(breakDuration)")
        
        debug(for: debugShift, "workedTimeWithoutBreak: \(roundedEndTime.timeIntervalSince(roundedStartTime))")
        
        debug(for: debugShift, "workedTimeWithBreak: \(workedTime)")
        
        debug(for: debugShift, "WorkedHours: \(hoursWorked)")
        
        
        // Determine base rate - use holiday salary if available
        let companyHasHolidaySalary = company.salary.holidaySalary != nil
        let isHoliday = false // fetch it from somewhere else
        
        debug(for: debugShift, "companyHasHolidaySalary: \(companyHasHolidaySalary)")
        debug(for: debugShift, "isHoliday: \(isHoliday)")
        
        
        
        let baseRate = companyHasHolidaySalary && isHoliday ?
        Double(company.salary.holidaySalary!) :
        Double(company.salary.baseSalary)
        
        debug(for: debugShift, "baseRate: \(baseRate)")
        
        // Calculate base salary for hours worked
        totalSalary += baseRate * hoursWorked
        
        
        debug(for: debugShift, "totalSalary: \(totalSalary)")
        
        // Handle overtime if applicable
        if let overtimeRate = company.salary.overtimeSalary,
           hoursWorked > overtimeRate.baseWorkHours {
            
            debug(for: debugShift, "overtimeRate: \(overtimeRate)")
            debug(for: debugShift, "hoursWorked: \(hoursWorked)")
            debug(for: debugShift, "baseWorkHours : \(overtimeRate.baseWorkHours )")
            
            
            
            let overtimeHours = hoursWorked - overtimeRate.baseWorkHours
            
            debug(for: debugShift, "overtimeHours: \(overtimeHours)")
            
            // Calculate overtime pay as the difference between overtime rate and base rate
            let overtimePayRate = Double(overtimeRate.overtimePayRate) - baseRate
            
            debug(for: debugShift, "overtimePayRate: \(overtimePayRate)")
            
            let overtimePay = overtimePayRate * overtimeHours
            debug(for: debugShift, "overtimePay: \(overtimePay)")
            
            totalSalary += overtimePay
            debug(for: debugShift, "after overtimePay totalSalary: \(totalSalary)")
            
        }
        
        // Add late salary if applicable
        if let lateSalary = company.salary.lateSalary {
            let lateNightSalary = calculateLateNightSalary(
                shiftStart: roundedStartTime,
                shiftEnd: roundedEndTime,
                lateSalary: lateSalary
            )
            totalSalary += lateNightSalary
            debug(for: debugShift, "after lateAmount totalSalary: \(totalSalary)")
        }
        
        return totalSalary
    }
    
    private func roundToNearestMinute(_ date: Date) -> Date {
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        components.second = 0
        
        return calendar.date(from: components)!
    }
    
    private func minutesSinceMidnight(_ date: Date) -> Int {
        let calendar = Calendar.current
        return calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
    }
    
    func calculateLateNightHours(shiftStart: Date, shiftEnd: Date, lateStart: Time, lateEnd: Time) -> Double {
        let calendar = Calendar.current
        
        // 深夜時間帯をDateに変換
        func createLatePeriod(for date: Date) -> (start: Date, end: Date) {
            var startComponents = calendar.dateComponents([.year, .month, .day], from: date)
            startComponents.hour = lateStart.hour
            startComponents.minute = lateStart.minute
            let startDate = calendar.date(from: startComponents)!
            
            var endComponents = startComponents
            endComponents.hour = lateEnd.hour
            endComponents.minute = lateEnd.minute

            // 深夜帯が日をまたぐ場合は+1日
            if lateEnd.hour < lateStart.hour || (lateEnd.hour == lateStart.hour && lateEnd.minute < lateStart.minute) {
                endComponents.day! += 1
            }
            let endDate = calendar.date(from: endComponents)!
            
            return (startDate, endDate)
        }
        
        var totalLateHours: Double = 0.0
        var currentDate = calendar.startOfDay(for: shiftStart)
        
        // ループはshiftEndの前日＋1日まで
        while currentDate < shiftEnd {
            let (lateStartDate, lateEndDate) = createLatePeriod(for: currentDate)
            
            // 深夜時間帯とシフト時間の重複を計算
            let overlapStart = max(shiftStart, lateStartDate)
            let overlapEnd = min(shiftEnd, lateEndDate)
            
            if overlapEnd > overlapStart {
                let seconds = overlapEnd.timeIntervalSince(overlapStart)
                totalLateHours += seconds / 3600.0
            }
            
            // 次の日へ
            guard let nextDay = calendar.date(byAdding: .day, value: 1, to: currentDate) else { break }
            currentDate = nextDay
        }
        
        return totalLateHours
    }
    
    private func calculateLateNightSalary(shiftStart: Date, shiftEnd: Date, lateSalary: LateSalary) -> Double {
        guard let lateAmount = lateSalary.lateSalary else { return 0 }
        
        let lateStart = Time(date: lateSalary.startTime!)
        let lateEnd = Time(date: lateSalary.endTime!)
        
        let lateNightHours = calculateLateNightHours(
            shiftStart: shiftStart,
            shiftEnd: shiftEnd,
            lateStart: lateStart,
            lateEnd: lateEnd
        )
        
        debug(for: "Fa", "Late night hours worked: \(lateNightHours)")
        
        // Calculate the difference between late night rate and base rate
        let lateNightRate = Double(lateAmount)
        let baseRate = Double(company.salary.baseSalary)
        let rateDifference = lateNightRate - baseRate
        
        // Only pay the difference for late night hours
        let lateNightSalary = rateDifference * lateNightHours
        debug(for: "Fa", "Late night salary (difference): \(lateNightSalary)")
        
        return lateNightSalary
    }
    
    
    func debug(for shift: String, _ text: String) {
        if self.name == shift {
            print(text)
        }
    }
}


