//
//  Date+Extensions.swift
//  Shift
//
//  Created by cmStudent on 2025/05/23.
//

import Foundation

extension Date {
    func startOfMonth() -> Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: Calendar.current.startOfDay(for: self)))!
    }
    
    func endOfMonth() -> Date {
        return Calendar.current.date(byAdding: DateComponents(month: 1, day: -1), to: self.startOfMonth())!
    }
    
    func startOfNextDay() -> Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: self))!
    }
}
