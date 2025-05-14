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
    
    @Published var needToUpdateUI: Bool = false
    
    @Published var isLoading: Bool = false
    
    @Published var error: Error?
    
    private let shiftUseCase: ShiftUseCase
    
    init(shiftUseCase: ShiftUseCase) {
        self.shiftUseCase = shiftUseCase
        self.addListenerToSelectedDate()
    }
    
    deinit {
        cancellables.removeAll()
    }

    private var cancellables = Set<AnyCancellable>()

    private func addListenerToSelectedDate() {
        $selectedDate
            .sink { [weak self] date in
                self?.fetchShifts(for: date)
            }
            .store(in: &cancellables)
    }
    
    func fetchShifts(for date: Date) {
        isLoading = true
        error = nil
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let predicate = #Predicate<Shift> { shift in
            shift.startTime >= startOfDay && shift.startTime < endOfDay
        }
        
        let descriptor = FetchDescriptor(predicate: predicate)
        
        do {
            let shifts = try shiftUseCase.fetchShifts(descriptor: descriptor)
            DispatchQueue.main.async { [weak self] in
                self?.shifts = shifts
                self?.isLoading = false
            }
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.error = error
                self?.isLoading = false
            }
        }
    }
    
    func deleteShift(_ shift: Shift) {
        isLoading = true
        error = nil
        
        do {
            try shiftUseCase.deleteShift(shift)
            fetchShifts(for: selectedDate)
            updateUI()
        } catch {
            DispatchQueue.main.async { [weak self] in
                self?.error = error
                self?.isLoading = false
            }
        }
    }
    
    func updateUI() {
        DispatchQueue.main.async { [weak self] in
            self?.needToUpdateUI = true
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
