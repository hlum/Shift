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
    var color: ColorName
    var endDate: Date
    var payDay: PayDay
    var salary: Salary
    
    @Relationship var shifts: [Shift] = []
    
    
    init(id: String, name: String, color: ColorName, endDate: Date, payDay: PayDay, salary: Salary) {
        self.id = id
        self.name = name
        self.color = color
        self.endDate = endDate
        self.payDay = payDay
        self.salary = salary
    }
}


enum ColorName: String, Codable, CaseIterable {
    case red
    case green
    case blue
    case orange
    case customPink
    
    var color: Color {
        switch self {
        case .red: return .red
        case .green: return .green
        case .blue: return .blue
        case .orange: return .orange
        case .customPink: return Color.pink.opacity(0.7)
        }
    }
}

