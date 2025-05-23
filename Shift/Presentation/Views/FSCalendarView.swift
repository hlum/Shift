//
//  FSCalendarView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import FSCalendar
import SwiftUI
import SwiftData

struct FSCalendarView: UIViewRepresentable {
    @Binding var selectedDate: Date
    @Binding var needToUpdateUI: Bool
    @Binding var publicHolidays: [Holiday]
    @Binding var shifts: [Shift]
    @Binding var salaryDates: [(date: Date, colorName: ColorName)]
    @Environment(\.container) private var container
    @Environment(\.locale) private var locale


    func makeUIView(context: Context) -> some UIView {
        let fsCalendar = FSCalendar()
        fsCalendar.delegate = context.coordinator
        fsCalendar.dataSource = context.coordinator
        context.coordinator.calendar = fsCalendar
        
        
        fsCalendar.scrollDirection = .vertical
        
        
        let preferredLanguage = Locale.preferredLanguages.first ?? "ja"
        let locale = Locale(identifier: preferredLanguage)
        fsCalendar.locale = locale
        
        fsCalendar.appearance.todayColor = .lightGray
        fsCalendar.appearance.titleTodayColor = .black

        
        fsCalendar.appearance.eventDefaultColor = .orange
        

        
        return fsCalendar
    }
    

    
    func makeCoordinator() -> Coordinator {
        return Coordinator(parent: self, shiftUseCase: container.shiftUseCase, holidayUseCase: container.holidayUseCase)
    }
    
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        guard let fsCalendar = uiView as? FSCalendar else { return }
        if needToUpdateUI {
            fsCalendar.reloadData()
            DispatchQueue.main.async {
                needToUpdateUI = false
            }
        }
    }
    
    
    
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource, FSCalendarDelegateAppearance {
        weak var calendar: FSCalendar?
        var parent: FSCalendarView
        var shiftUseCase: ShiftUseCase
        var holidayUseCase: HolidayUseCase
        let dateFormatter = DateFormatter()

        
        init(parent: FSCalendarView, shiftUseCase: ShiftUseCase, holidayUseCase: HolidayUseCase) {
            self.parent = parent
            self.shiftUseCase = shiftUseCase
            self.holidayUseCase = holidayUseCase
        }
        
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }
        
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, fillDefaultColorFor date: Date) -> UIColor? {
            // Find the SalaryDate for the given date
            if let salaryDate = parent.salaryDates.first(where: { Calendar.current.isDate($0.date, inSameDayAs: date) }) {
                return UIColor(salaryDate.colorName.color)
            }
            return nil
        }
        func calendar(_ calendar: FSCalendar, appearance: FSCalendarAppearance, titleDefaultColorFor date: Date) -> UIColor? {
            let isPublicHoliday = parent.publicHolidays.contains(where: { Calendar.current.isDate($0.date, inSameDayAs: date) })
            if  isPublicHoliday || holidayUseCase.isWeekend(date) {
                return .red
            }
            return nil
        }
        
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            let shiftsForDate = parent.shifts.filter { Calendar.current.isDate($0.startTime, inSameDayAs: date) }
            return shiftsForDate.count
        }
    }
}
