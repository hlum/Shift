//
//  Company.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Company: Identifiable{
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var color: String
    var endDate: Date
    var payDay: PayDay
    var salary: Salary
    
    @Relationship var shifts: [Shift] = []
    
    
    init(id: String, name: String, color: String, endDate: Date, payDay: PayDay, salary: Salary) {
        self.id = id
        self.name = name
        self.color = color
        self.endDate = endDate
        self.payDay = payDay
        self.salary = salary
    }
}
