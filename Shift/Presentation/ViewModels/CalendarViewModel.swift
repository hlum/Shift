//
//  CalendarViewModel.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation

final class CalendarViewModel: ObservableObject {
    @Published var shifts: [Shift] = []
    
    private let shiftUseCase: ShiftUseCase
    
    init(shiftUseCase: ShiftUseCase) {
        self.shiftUseCase = shiftUseCase
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
