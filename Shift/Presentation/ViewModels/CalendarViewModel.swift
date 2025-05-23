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
    
    @Published var shiftsForSelectedDate: [Shift] = []
    @Published var allShifts: [Shift] = []
    
    @Published var holidaysForSelectedDate: [Holiday] = []
    @Published var publicHolidays: [Holiday] = []
    
    @Published var showAddShiftView: Bool = false
    
    @Published var needToUpdateUI: Bool = false
    
    @Published var isLoading: Bool = false
    
    @Published var error: Error?
    
    private let shiftUseCase: ShiftUseCase
    private let holidayUseCase: HolidayUseCase
    private let payDayUseCase: PayDayUseCase
    
    init(shiftUseCase: ShiftUseCase, holidayUseCase: HolidayUseCase, paydayUseCase: PayDayUseCase) {
        self.shiftUseCase = shiftUseCase
        self.holidayUseCase = holidayUseCase
        self.payDayUseCase = paydayUseCase
        self.addListenerToSelectedDate()

        Task {
            await fetchAllShifts()
            await self.getShiftForSelectedDate(for: Date())
        }
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
                    await self?.getShiftForSelectedDate(for: date)
                    await self?.getHoliday(for: date)
                }
            }
            .store(in: &cancellables)
    }
    
    @MainActor
    func fetchAllShifts() async {
        isLoading = true
        error = nil
        
        do {
            self.allShifts = try await shiftUseCase.fetchShifts()
            self.isLoading = false
            self.error = nil
        } catch {
            self.error = error
            self.isLoading = false
            print("Error fetching shifts: \(error.localizedDescription)")
        }
        
    }
    
    @MainActor
    func getShiftForSelectedDate(for date: Date) {
        isLoading = true
        error = nil
        
        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        self.shiftsForSelectedDate = allShifts.filter { shift in
            shift.startTime >= startOfDay && shift.startTime < endOfDay
        }
        
    }
    
    @MainActor
    func getHoliday(for date: Date) {
        self.holidaysForSelectedDate = publicHolidays.filter({ item in
            Calendar.current.isDate(item.date, inSameDayAs: date)
        })
    }
    
    func fetchAllHolidays() {
        Task { @MainActor in
            self.publicHolidays = await holidayUseCase.fetchHolidays()
            self.updateUI()
        }
    }
    
    @MainActor
    func deleteShift(_ shift: Shift) async {
        isLoading = true
        error = nil
        
        do {
            try await shiftUseCase.deleteShift(shift)
            await fetchAllShifts()
            getShiftForSelectedDate(for: selectedDate)
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
