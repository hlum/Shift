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
