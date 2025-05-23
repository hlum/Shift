//
//  PayDayUseCase.swift
//  Shift
//
//  Created by cmStudent on 2025/05/22.
//

import Foundation

class PayDayUseCase {
    private let holidayUseCase: HolidayUseCase
    
    init(holidayUseCase: HolidayUseCase) {
        self.holidayUseCase = holidayUseCase
    }
    
    func getActualPayDay(
        holidayPayChange: Bool,
        holidayPayEarly: Bool,
        plainPayDay: Date
    ) async -> Date {
        guard holidayPayChange else {
            // if holidayPayChange is false then the date won't change
            return plainPayDay
        }
        
        if holidayPayEarly {
            let earliestDateBeforeHoliday = await holidayUseCase.getDateBeforeHoliday(plainPayDay)
            print("Return early date: \(earliestDateBeforeHoliday.formatted(.dateTime.month().day()))")
            return earliestDateBeforeHoliday
        } else {
            let earliestDateAfterHoliday = await holidayUseCase.getDateAfterHoliday(plainPayDay)
            return earliestDateAfterHoliday
        }
        
        
    }
}

class MockPayDayUseCase: PayDayUseCase {
    init() {
        super.init(holidayUseCase: MockHolidayUseCase())
    }
    
    override func getActualPayDay(
        holidayPayChange: Bool,
        holidayPayEarly: Bool,
        plainPayDay: Date
    ) async -> Date {
        return plainPayDay
    }
}
