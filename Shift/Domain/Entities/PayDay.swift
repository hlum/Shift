//
//  PayDay.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import Foundation
import SwiftData

@Model
final class PayDay {
    var payDay: PayDayType
    var payTiming: PayTiming
    var holidayPayDayChange: Bool
    var holidayPayEarly: Bool
    
    init(payDay: PayDayType, payTiming: PayTiming, holidayPayDayChange: Bool, holidayPayEarly: Bool) {
        self.payDay = payDay
        self.payTiming = payTiming
        self.holidayPayDayChange = holidayPayDayChange
        self.holidayPayEarly = holidayPayEarly
    }
}

enum PayTiming: Codable, Equatable, CaseIterable {
    case currentMonth      // 今月払い
    case nextMonth         // 翌月払い
    case nextNextMonth     // 翌々月払い
}

extension PayTiming {
    var displayString: String {
        switch self {
        case .currentMonth: return "Current Month"
        case .nextMonth: return "Next Month"
        case .nextNextMonth: return "Next-Next Month"
        }
    }
    
    
    /// Returns the (year, month) tuple for the payment based on the pay timing
    func paymentMonth(forWorkMonth workMonth: Int, year: Int) -> (year: Int, month: Int) {
        let dateComponents = DateComponents(year: year, month: workMonth)
        let calendar = Calendar.current
        let offset: Int
        switch self {
        case .currentMonth: offset = 0
        case .nextMonth: offset = 1
        case .nextNextMonth: offset = 2
        }
        if let payDate = calendar.date(byAdding: .month, value: offset, to: calendar.date(from: dateComponents)!) {
            let comps = calendar.dateComponents([.year, .month], from: payDate)
            return (comps.year!, comps.month!)
        }
        return (year, workMonth)
    }
    
}



enum PayDayType: Codable, Equatable, Hashable {
    case day(Int)        // 1...31 (or 1...30 if you want to limit)
    case endOfMonth
}

extension PayDayType {
    var displayString: String {
        switch self {
        case .day(let d): return "\(d)"
        case .endOfMonth: return "End of Month"
        }
    }
    
    
    private func date(forMonth month: Int, year: Int, calendar: Calendar = .current) -> Date? {
        var components = DateComponents()
        components.year = year
        components.month = month
        switch self {
        case .day(let day):
            components.day = day
        case .endOfMonth:
            if let date = calendar.date(from: components),
               let range = calendar.range(of: .day, in: .month, for: date) {
                components.day = range.count
            } else {
                return nil
            }
        }
        return calendar.date(from: components)
    }
    
    /// Returns the actual pay date for a given work year, work month, and pay timing.
    func payDate(
        forWorkMonth workMonth: Int,
        workYear: Int,
        payTiming: PayTiming,
        calendar: Calendar = .current
    ) -> Date? {
        // Calculate the payment month and year based on timing
        let dateComponents = DateComponents(year: workYear, month: workMonth)
        let offset: Int
        switch payTiming {
        case .currentMonth: offset = 0
        case .nextMonth: offset = 1
        case .nextNextMonth: offset = 2
        }
        guard let paymentMonthDate = calendar.date(byAdding: .month, value: offset, to: calendar.date(from: dateComponents)!) else {
            return nil
        }
        let comps = calendar.dateComponents([.year, .month], from: paymentMonthDate)
        guard let payYear = comps.year, let payMonth = comps.month else {
            return nil
        }
        // Use your existing logic to get the actual pay date in the payment month
        return self.date(forMonth: payMonth, year: payYear, calendar: calendar)
    }
    
}
