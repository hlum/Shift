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
    @Attribute(.unique)
    var id: String = UUID().uuidString
    var name: String
    var color: ColorName
    var settleMentDate: SettlementDate
    var payDay: PayDay
    var salary: Salary
    
    @Relationship(deleteRule: .cascade)
    var shifts: [Shift]?
    
    
    init(id: String, name: String, color: ColorName, endDate: SettlementDate, payDay: PayDay, salary: Salary) {
        self.id = id
        self.name = name
        self.color = color
        self.settleMentDate = endDate
        self.payDay = payDay
        self.salary = salary
    }
}

enum SettlementDate: Codable, Equatable, Hashable {
    case day(Int)        // 1 to 30
    case endOfMonth      // Special case for "end of month"
    
    
    var displayString: String {
        switch self {
        case .day(let num): return "\(num)"
        case .endOfMonth: return "End of Month"
        }
    }
    
    func toDate(forMonth month: Int, year: Int, calendar: Calendar = .current) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        
        switch self {
        case .day(let day):
            components.day = day
        case .endOfMonth:
            // Get the last day of the month
            if let range = calendar.range(of: .day, in: .month, for: calendar.date(from: components)!) {
                components.day = range.count
            } else {
                return nil
            }
        }
        return calendar.date(from: components)
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

