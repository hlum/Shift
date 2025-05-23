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
    
    
    @Published var salaryDates: [(date: Date, colorName: ColorName)] = []
    
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
            await getSalaryDate()
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
    func getSalaryDate() async {
        let shiftsWithDifferentMonths = self.getShiftsWithDifferentMonths(from: self.allShifts)
        print("Shift with different count: \(shiftsWithDifferentMonths.count)")
        for shift in shiftsWithDifferentMonths {
            let holidayPayChange: Bool = shift.company.payDay.holidayPayDayChange
            let holidayPayEarly: Bool = shift.company.payDay.holidayPayEarly
            print("HolidayPayEarly: \(holidayPayEarly)")
            let payTiming = shift.company.payDay.payTiming
            let color: ColorName = shift.company.color
            
            let components = Calendar.current.dateComponents([.year,. month], from: shift.startTime)
            let workYear: Int = components.year ?? 0
            let workMonth: Int = components.month ?? 0
            
            let plainPayDay: Date = shift.company.payDay.payDay.payDate(forWorkMonth: workMonth, workYear: workYear, payTiming: payTiming)!

            let salaryDate = await payDayUseCase.getActualPayDay(holidayPayChange: holidayPayChange , holidayPayEarly: holidayPayEarly, plainPayDay: plainPayDay)
            print("Salary Dates: \(salaryDate.formatted(.dateTime.month().day().hour().minute().second()))")

            self.salaryDates.append((salaryDate, color))
        }
    }
    
    private func getShiftsWithDifferentMonths(from shifts: [Shift]) -> [Shift] {
        guard !shifts.isEmpty else {
            Logger.standard.warning("There is no shifts")
            return []
        }
        var seenMonthsCompany = Set<String>()

        var result: [Shift] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM" // Use year and month to handle multiple years

        for shift in shifts {
            let monthKey = formatter.string(from: shift.startTime)
            let companyName = shift.company.name
            let monthKeyCompany = "\(companyName)-\(monthKey)"
            
            
            if !seenMonthsCompany.contains(monthKeyCompany) {
                seenMonthsCompany.insert(monthKeyCompany)
                result.append(shift)
            }
        }
        return result
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
            await getSalaryDate()
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
            holidayUseCase: MockHolidayUseCase(),
            paydayUseCase: MockPayDayUseCase()
        )
        
        return viewModel
    }
}
