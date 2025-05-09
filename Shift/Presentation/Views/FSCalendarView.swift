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
    @Environment(\.modelContext) private var modelContext


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
        let shiftUseCase = ShiftUseCase(shiftRepository: SwiftDataShiftRepo(context: modelContext ))
        return Coordinator(parent: self, shiftUseCase: shiftUseCase)
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
    
    
    
    
    class Coordinator: NSObject, FSCalendarDelegate, FSCalendarDataSource {
        weak var calendar: FSCalendar?
        var parent: FSCalendarView
        var shiftUseCase: ShiftUseCase

        let dateFormatter = DateFormatter()
        
        init(parent: FSCalendarView, shiftUseCase: ShiftUseCase) {
            self.parent = parent
            self.shiftUseCase = shiftUseCase
        }
        
        
        func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
            parent.selectedDate = date
        }
        
        
        func calendar(_ calendar: FSCalendar, numberOfEventsFor date: Date) -> Int {
            let calendar = Calendar.current
            let startOfDay = calendar.startOfDay(for: date)
            let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
            
            let predicate = #Predicate<Shift> { shift in
                shift.startTime >= startOfDay && shift.startTime < endOfDay
            }
            
            let descriptor = FetchDescriptor(predicate: predicate)
            
            do {
                let shifts = try shiftUseCase.fetchShifts(descriptor: descriptor)
                return shifts.count
            } catch {
                print("Can't fetch shifts: \(error.localizedDescription)")
                return 0
            }
        }
        
    }
}
