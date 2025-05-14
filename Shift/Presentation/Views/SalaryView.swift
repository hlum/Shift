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
    @Published var selectedDate: Date = Date()
    @Published var shifts: [Shift] = []
    @Published var totalSalary: Double = 0
    
    init(shiftUseCase: ShiftUseCase) {
        self.shiftUseCase = shiftUseCase
    }
    
    
    func fetchShifts() {
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
            DispatchQueue.main.async {
                self.shifts = shifts
                self.getTotalSalary()
            }
        } catch {
            print("Error fetching shifts: \(error.localizedDescription)")
        }
    }
    
    
    func getTotalSalary() {
        totalSalary = 0
        guard !shifts.isEmpty else {
            return
        }
        var total = 0.0
        for shift in shifts {
            total += shift.salary
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
    
    init(shiftUseCase: ShiftUseCase = MockShiftUseCase()) {
        _vm = StateObject(wrappedValue: SalaryViewModel(shiftUseCase: shiftUseCase))
    }
    
    var body: some View {
        VStack {
            title()
            Spacer()
            
            HStack {
                Image(systemName: "lessthan.circle")
                    .onTapGesture {
                        let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: vm.selectedDate)!
                        vm.selectedDate = lastMonth
                        vm.fetchShifts()
                    }
                Spacer()
                
                Text("\(vm.totalSalary)")
                
                Spacer()
                Image(systemName: "greaterthan.circle")
                    .onTapGesture {
                        let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: vm.selectedDate)!
                        vm.selectedDate = nextMonth
                        vm.fetchShifts()
                    }
            }
            
            Spacer()
        }
        .onAppear {
            vm.fetchShifts()
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
