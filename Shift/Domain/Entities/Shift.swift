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


extension Shift {
    var salary: Double {
        // Calculate the Salary based on the company rules
        var totalSalary: Double = 0
        
        // Add transportation expense
        totalSalary += Double(company.salary.transportationExpense)
        
        if company.salary.paymentType == .oneDay {
            // For one-day payment type, just return base salary + transportation
            return totalSalary + Double(company.salary.baseSalary)
        }
        
        // For hourly payment type
        let workedTime = endTime.timeIntervalSince(startTime) - breakDuration
        let hoursWorked = workedTime / 3600 // Convert seconds to hours
        
        // Determine base rate - use holiday salary if available
        let companyHasHolidaySalary = company.salary.holidaySalary != nil
        let isHoliday = true // fetch it from somewhere else

        let baseRate = companyHasHolidaySalary && isHoliday ? 
            Double(company.salary.holidaySalary!) : 
            Double(company.salary.baseSalary)
        
        // Calculate base salary for hours worked
        totalSalary += baseRate * hoursWorked
        
        // Handle overtime if applicable
        if let overtimeRate = company.salary.overtimeSalary,
           hoursWorked > overtimeRate.baseWorkHours {
            let overtimeHours = hoursWorked - overtimeRate.baseWorkHours
            // Calculate overtime pay as the difference between overtime rate and base rate
            let overtimePayRate = Double(overtimeRate.overtimePayRate) - baseRate
            let overtimePay = overtimePayRate * overtimeHours
            totalSalary += overtimePay
        }
        
        // Add late salary if applicable
        if let lateSalary = company.salary.lateSalary,
           let lateAmount = lateSalary.lateSalary {
            totalSalary += Double(lateAmount)
        }
        
        return totalSalary
    }
}


