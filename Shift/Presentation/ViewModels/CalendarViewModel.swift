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
    @Published var holidaysForSelectedDate: [Holiday] = []
    @Published var publicHolidays: [Holiday] = []
    
    @Published var showAddShiftView: Bool = false
    
    @Published var needToUpdateUI: Bool = false
    
    @Published var isLoading: Bool = false
    
    @Published var error: Error?
    
    private let shiftUseCase: ShiftUseCase
    private let holidayUseCase: HolidayUseCase
    
    init(shiftUseCase: ShiftUseCase, holidayUseCase: HolidayUseCase) {
        self.shiftUseCase = shiftUseCase
        self.holidayUseCase = holidayUseCase
        self.addListenerToSelectedDate()
        fetchAllHolidays()
    }
    
    deinit {
        cancellables.removeAll()
    }

    private var cancellables = Set<AnyCancellable>()

    private func addListenerToSelectedDate() {
        $selectedDate
            .sink { [weak self] date in
                Task {
                    await self?.fetchShifts(for: date)
                    await self?.fetchHolidays(for: date)
                }
            }
            .store(in: &cancellables)
    }
    
    func fetchShifts(for date: Date) async {
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
            let shifts = try await shiftUseCase.fetchShifts(descriptor: descriptor)
            await MainActor.run { [weak self] in
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
    
    
    
    func fetchAllHolidays() {
        Task { @MainActor in
            self.publicHolidays = await holidayUseCase.fetchHolidays()
            self.updateUI()
        }
    }
    
    
    func fetchHolidays(for date: Date) async {
        let holidaysForSelectedDate = await holidayUseCase.fetchHoliday(for: date)
        await MainActor.run {
            self.holidaysForSelectedDate = holidaysForSelectedDate
        }
        self.updateUI()
    }
    
    func deleteShift(_ shift: Shift) async {
        isLoading = true
        error = nil
        
        do {
            try await shiftUseCase.deleteShift(shift)
            await fetchShifts(for: selectedDate)
            updateUI()
        } catch {
            await MainActor.run { [weak self] in
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
        let viewModel = CalendarViewModel(
            shiftUseCase: MockShiftUseCase(),
            holidayUseCase: MockHolidayUseCase()
        )
        
        return viewModel
    }
}
