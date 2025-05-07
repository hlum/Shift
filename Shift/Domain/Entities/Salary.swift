//
//  Salary.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import Foundation
import SwiftData

@Model
final class Salary {
    var baseSalary: Int
    var transportationExpense: Int
    var holidaySalary: Int?
    var overtimeSalary: OverTimeSetting?
    var lateSalary: LateSalary?
    var paymentTypeRaw: String

    var paymentType: PaymentType {
        get { PaymentType(rawValue: paymentTypeRaw) ?? .oneDay }
        set { paymentTypeRaw = newValue.rawValue }
    }

    init(baseSalary: Int, transportationExpense: Int, holidaySalary: Int? = nil, overtimeSalary: OverTimeSetting? = nil, lateSalary: LateSalary? = nil, paymentType: PaymentType) {
        self.baseSalary = baseSalary
        self.transportationExpense = transportationExpense
        self.holidaySalary = holidaySalary
        self.overtimeSalary = overtimeSalary
        self.lateSalary = lateSalary
        self.paymentTypeRaw = paymentType.rawValue
    }
}

extension Salary {
    var isHourly: Bool { paymentType == .hourly }
    var isOneDay: Bool { paymentType == .oneDay }
}


@Model
class OverTimeSetting {
    var baseWorkHours: Double
    var overtimePayRate: Int

    init(baseWorkHours: Double, overtimePayRate: Int) {
        self.baseWorkHours = baseWorkHours
        self.overtimePayRate = overtimePayRate
    }
}


enum PaymentType: String, Codable, CaseIterable {
    case oneDay
    case hourly
}
 

@Model
class LateSalary {
    var lateSalary: Int?
    var startTime: Date?
    var endTiem: Date?
    
    init(lateSalary: Int? = nil, startTime: Date? = nil, endTiem: Date? = nil) {
        self.lateSalary = lateSalary
        self.startTime = startTime
        self.endTiem = endTiem
    }
}
