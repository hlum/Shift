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
    var payDay: Date
    var holidayPayDayChange: Bool
    var holidayPayEarly: Bool
    
    init(payDay: Date, holidayPayDayChange: Bool, holidayPayEarly: Bool) {
        self.payDay = payDay
        self.holidayPayDayChange = holidayPayDayChange
        self.holidayPayEarly = holidayPayEarly
    }
}
