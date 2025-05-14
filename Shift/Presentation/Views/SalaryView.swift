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
    @Published var isLoading: Bool = false
    @Published var error: Error?
    let countryCode: String
    
    init(shiftUseCase: ShiftUseCase, holidayUseCase: HolidayUseCase, countryCode: String?) {
        self.shiftUseCase = shiftUseCase
        self.holidayUseCase = holidayUseCase
        self.countryCode = countryCode ?? "US"
    }
    
    func fetchShifts() async {
        await MainActor.run { isLoading = true }
        defer { Task { @MainActor in isLoading = false } }
        
        let calendar = Calendar.current
        guard let startOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate)),
              let startOfNextMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            await MainActor.run { error = SalaryError.invalidDate }
            return
        }
        
        let predicate = #Predicate<Shift>{ shift in
            shift.startTime >= startOfMonth && shift.startTime < startOfNextMonth
        }
        
        do {
            let descriptor = FetchDescriptor<Shift>(predicate: predicate)
            let fetchedShifts = try await shiftUseCase.fetchShifts(descriptor: descriptor)
            await MainActor.run { self.shifts = fetchedShifts }
            await calculateTotalSalary(for: fetchedShifts)
        } catch {
            await MainActor.run { self.error = error }
        }
    }
    
    @MainActor
    private func calculateTotalSalary(for shifts: [Shift]) async {
        guard !shifts.isEmpty else {
            totalSalary = 0
            return
        }
        
        do {
            let salaries = try await withThrowingTaskGroup(of: Double.self) { group in
                for shift in shifts {
                    group.addTask {
                        try await shift.getSalary(holidayUseCase: self.holidayUseCase, countryCode: self.countryCode)
                    }
                }
                
                var total: Double = 0
                for try await salary in group {
                    total += salary
                }
                return total
            }
            
            totalSalary = salaries
        } catch {
            self.error = error
        }
    }
}

enum SalaryError: LocalizedError {
    case invalidDate
    
    var errorDescription: String? {
        switch self {
        case .invalidDate:
            return "Invalid date range for salary calculation"
        }
    }
}

@MainActor
struct SalaryView: View {
    @StateObject var vm: SalaryViewModel
    @Environment(\.locale) private var locale
    
    init(shiftUseCase: ShiftUseCase = MockShiftUseCase(), holidayUseCase: HolidayUseCase = MockHolidayUseCase(), locale: Locale? = .current) {
        _vm = StateObject(wrappedValue: SalaryViewModel(shiftUseCase: shiftUseCase, holidayUseCase: holidayUseCase, countryCode: locale?.region?.identifier))
    }
    
    var body: some View {
        VStack {
            title()
            Spacer()
            
            if vm.isLoading {
                ProgressView()
            } else if let error = vm.error {
                Text(error.localizedDescription)
                    .foregroundColor(.red)
            } else {
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
