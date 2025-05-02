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
    var holidaySalary: Int
    var lateSalary: LateSalary?
    var overtimeSalary: Int
    
    init(baseSalary: Int, transportationExpense: Int, holidaySalary: Int, lateSalary: LateSalary?, overtimeSalary: Int) {
        self.baseSalary = baseSalary
        self.transportationExpense = transportationExpense
        self.holidaySalary = holidaySalary
        self.lateSalary = lateSalary
        self.overtimeSalary = overtimeSalary
    }
    
}

@Model class LateSalary {
    var salary: Int
    var startTime: Date
    var endTime: Date
    
    init(salary: Int, startTime: Date, endTime: Date) {
        self.salary = salary
        self.startTime = startTime
        self.endTime = endTime
    }
}
