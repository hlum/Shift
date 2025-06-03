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

struct ShiftSegment {
    let start: Date
    let end: Date
    let isHoliday: Bool
}

class ShiftSplitter {
    static let shared: ShiftSplitter = ShiftSplitter()

    func splitShiftByDay(
        shiftStart: Date,
        shiftEnd: Date,
        holidays: [Date]
    ) -> [ShiftSegment] {
        var segments: [ShiftSegment] = []
        var currentStart = shiftStart
        let calendar = Calendar.current

        while currentStart < shiftEnd {
            let nextDay = calendar.date(byAdding: .day, value: 1, to: currentStart)!
            let segmentEnd = min(shiftEnd, calendar.startOfDay(for: nextDay))
            let holiday = isHoliday(date: currentStart, holidays: holidays)
            segments.append(ShiftSegment(start: currentStart, end: segmentEnd, isHoliday: holiday))
            currentStart = segmentEnd
        }
        return segments
    }
    
    private func isHoliday(date: Date, holidays: [Date]) -> Bool {
        let calendar = Calendar.current
        return holidays.contains { calendar.isDate($0, inSameDayAs: date) }
    }
    
}
