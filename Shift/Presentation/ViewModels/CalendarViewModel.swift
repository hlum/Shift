//
//  CalendarViewModel.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation


final class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Date()
    @Published var shifts: [Shift] = []
    
    private let shiftUseCase: ShiftUseCase
    
    init(shiftUseCase: ShiftUseCase) {
        self.shiftUseCase = shiftUseCase
        fetchShifts()
    }
    
    
    func addShift(_ shift: Shift) {
        shiftUseCase.addShift(shift)
        self.fetchShifts()
    }
    
    
    func fetchShifts() {
        do {
            let shifts = try shiftUseCase.fetchShifts()
            
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
