//
//  SalaryView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/09.
//

import SwiftUI
import SwiftData

final class SalaryViewModel: ObservableObject {
    private let shiftUseCase: ShiftUseCase
    private let holidayUseCase: HolidayUseCase
    
    @Published var selectedDate: Date = Date()
    @Published var shifts: [Shift] = []
    @Published var totalSalary: Double = 0
    
    init(shiftUseCase: ShiftUseCase, holidayUseCase: HolidayUseCase) {
        self.shiftUseCase = shiftUseCase
        self.holidayUseCase = holidayUseCase
    }
    
    
    func fetchShifts() async {
        let calendar = Calendar.current

        // 🌙 月初め（例：2025-05-01 00:00:00）
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)) else {
            
            print("Can't get start of month")
            return
        }

        // 🌕 翌月の月初め（例：2025-06-01 00:00:00）
        guard let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            print("Can't get start of next month")
            return
        }
        
        let predicate = #Predicate<Shift>{ shift in
            shift.startTime >= startOfMonth && shift.startTime < startOfNextMonth
        }
        
        
        let descriptor = FetchDescriptor<Shift>(predicate: predicate)
        do {
            let shifts = try shiftUseCase.fetchShifts(descriptor: descriptor)
            Task { @MainActor in
                self.shifts = shifts
                await self.getTotalSalary(shifts: self.shifts)
            }
            

        } catch {
            print("Error fetching shifts: \(error.localizedDescription)")
        }
    }
    
    
    private func getTotalSalary(shifts: [Shift]) async {
        DispatchQueue.main.async {
            self.totalSalary = 0
        }
        guard !shifts.isEmpty else {
            print("There is no shift found to calculate total salary.")
            return
        }
        var total = 0.0
        for shift in shifts {
            do {
                let salary = try await shift.getSalary(holidayUseCase: holidayUseCase)
                total += salary
            } catch {
                print("Error calculating total salary: \(error.localizedDescription)")
            }
        }
        DispatchQueue.main.async {
            self.totalSalary = total
        }
        
    }
}

@MainActor
struct SalaryView: View {
    @StateObject var vm: SalaryViewModel
    @Environment(\.locale) private var locale
    
    init(shiftUseCase: ShiftUseCase = MockShiftUseCase(), holidayUseCase: HolidayUseCase = MockHolidayUseCase()) {
        _vm = StateObject(wrappedValue: SalaryViewModel(shiftUseCase: shiftUseCase, holidayUseCase: holidayUseCase))
    }
    
    var body: some View {
        VStack {
            title()
            Spacer()
            
            HStack {
                Image(systemName: "lessthan.circle")
                    .onTapGesture {
                        Task {
                            let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: vm.selectedDate)!
                            vm.selectedDate = lastMonth
                            await vm.fetchShifts()
                        }
                    }
                Spacer()
                
                Text("\(vm.totalSalary)")
                
                Spacer()
                Image(systemName: "greaterthan.circle")
                    .onTapGesture {
                        Task {
                            let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: vm.selectedDate)!
                            vm.selectedDate = nextMonth
                            await vm.fetchShifts()
                        }
                    }
            }
            
            Spacer()
        }
        .task {
            await vm.fetchShifts()
        }
    }
    
    func title() -> some View {
        let formatter = DateFormatter()
        formatter.locale = locale
        formatter.dateFormat = "M/yyyy"
        let dateString = formatter.string(from: vm.selectedDate)
        return HStack {
            Text(dateString)
        }
        .frame(maxWidth: .infinity)
        .foregroundStyle(.black)
        .font(.headline)
        .fontWeight(.heavy)
    }
}

#Preview {
    NavigationStack {
        SalaryView()
            .injectDependencies(DependencyContainer(
                modelContainer: try! ModelContainer(for: Schema([Company.self, Shift.self]))
            ))
    }
}
