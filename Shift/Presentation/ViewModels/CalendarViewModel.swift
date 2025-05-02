//
//  CalendarViewModel.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData

final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var shifts: [Shift] = []
    
    private let shiftUseCase: ShiftUseCase
    
    init(shiftUseCase: ShiftUseCase) {
        self.shiftUseCase = shiftUseCase
        fetchShifts()
    }
    
    
    func addShift(_ shift: Shift) {
        do {
            try shiftUseCase.addShift(shift)
            self.fetchShifts()
        } catch {
            print("Error adding shift: \(error.localizedDescription)")
        }
    }
    
    
    func fetchShifts() {
        do {
            let shifts = try shiftUseCase.fetchShifts(descriptor: FetchDescriptor<Shift>())
            
            DispatchQueue.main.async {
                self.shifts = shifts
            }
            
        } catch {
            print("Error fetching shifts: \(error.localizedDescription)")
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
