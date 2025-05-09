//
//  CalendarViewModel.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData
import Combine

final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var shifts: [Shift] = []
    
    @Published var showAddShiftView: Bool = false
    
    private let shiftUseCase: ShiftUseCase
    
    init(shiftUseCase: ShiftUseCase) {
        self.shiftUseCase = shiftUseCase
        self.addListenerToSelectedDate()
    }
    
    private var cancellables = Set<AnyCancellable>()


    func addListenerToSelectedDate() {
        $selectedDate
            .sink { [weak self] date in
                self?.fetchShifts(for: date)
            }
            .store(in: &cancellables)
    }
    
    
    func fetchShifts(for date: Date) {
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<Shift> { shift in
            shift.startTime >= startOfDay && shift.startTime < endOfDay
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            let shifts = try shiftUseCase.fetchShifts(descriptor: descriptor)
            
            DispatchQueue.main.async {
                self.shifts = shifts
            }
            
        } catch {
            print("Error fetching shifts: \(error.localizedDescription)")
        }
    }
    
    
    func deleteShift(_ shift: Shift) {
        do {
            try shiftUseCase.deleteShift(shift)
            fetchShifts(for: selectedDate)
        } catch {
            print("Error deleting shift: \(error.localizedDescription)")
        }
    }
    
}


// Preview 用のViewModel
extension CalendarViewModel {
    static func preview() -> CalendarViewModel {
        let repo = MockShiftRepository()
        let useCase = ShiftUseCase(shiftRepository: repo)
        let viewModel = CalendarViewModel(shiftUseCase: useCase)
        
        return viewModel
    }
}
