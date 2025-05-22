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
    private let salaryUseCase: SalaryUseCaseProtocol
    
    @Published var selectedDate: Date = Date()
    @Published var shifts: [Shift] = []
    @Published var totalSalary: Double = 0
    @Published var desiredSalary: Int = 80000
    @Published var showDesiredSalaryInput: Bool = false
    @Published var isLoading: Bool = false
    @Published var error: Error?
    let countryCode: String
    
    init(
        shiftUseCase: ShiftUseCase,
        salaryUseCase: SalaryUseCaseProtocol,
        countryCode: String?
    ) {
        self.shiftUseCase = shiftUseCase
        self.salaryUseCase = salaryUseCase
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
        do {
            totalSalary = try await salaryUseCase.calculateMonthlySalary(for: shifts, countryCode: countryCode)
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
    
    init(
        shiftUseCase: ShiftUseCase = MockShiftUseCase(),
        salaryUseCase: SalaryUseCaseProtocol = MockSalaryUseCase(),
        locale: Locale? = .current
    ) {
        _vm = StateObject(wrappedValue: SalaryViewModel(
            shiftUseCase: shiftUseCase,
            salaryUseCase: salaryUseCase,
            countryCode: locale?.region?.identifier
        ))
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
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        vm.showDesiredSalaryInput = true
                    }
                } label: {
                    VStack {
                        Text("Desired salary")
                            .font(.headline.bold())
                            .foregroundStyle(.black)
                        Text("\(vm.desiredSalary)$")
                            .foregroundStyle(.black)
                    }
                    .overlay(alignment: .bottomTrailing, content: {
                        Image(systemName: "pencil")
                            .font(.headline)
                        
                    })
                    .padding()
                }

                
                HStack {
                    Image(systemName: "lessthan.circle")
                        .font(.title)
                        .padding()
                        .onTapGesture {
                            Task {
                                let lastMonth = Calendar.current.date(byAdding: .month, value: -1, to: vm.selectedDate)!
                                vm.selectedDate = lastMonth
                                await vm.fetchShifts()
                            }
                        }
                    Spacer()
                    
                        
                    SalaryCircleView(desiredSalary: $vm.desiredSalary, salary: $vm.totalSalary)
                    
                    
                    Spacer()
                    Image(systemName: "greaterthan.circle")
                        .font(.title)
                        .padding()
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
            Text("Details")
        }
        .overlay(alignment: .center, content: {
            if vm.showDesiredSalaryInput {
                desiredSalaryInputView
            }
        })
        .task {
            await vm.fetchShifts()
        }
    }
    
    
    private var desiredSalaryInputView: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                Text("Set Desired Salary")
                    .font(.title2.bold())
                Spacer()
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        vm.showDesiredSalaryInput = false
                    }
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundStyle(.gray)
                        .contentTransition(.symbolEffect(.replace))
                }
            }
            .padding(.horizontal)
            
            // Input Section
            VStack(alignment: .leading, spacing: 8) {
                Text("Annual Salary")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                HStack {
                    Text("$")
                        .font(.title2.bold())
                        .foregroundStyle(.secondary)
                    
                    TextField("Enter amount", text: Binding(
                        get: { String(vm.desiredSalary) },
                        set: { newValue in
                            // Only allow numbers
                            let filtered = newValue.filter { "0123456789".contains($0) }
                            if let newValueInt = Int(filtered) {
                                vm.desiredSalary = newValueInt
                            } else {
                                vm.desiredSalary = 0
                            }
                        }
                    ))
                    .font(.title2.bold())
                    .keyboardType(.numberPad)
                    .textFieldStyle(.plain)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding(.horizontal)
            
            // Action Buttons
            HStack(spacing: 16) {
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        vm.showDesiredSalaryInput = false
                    }
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundStyle(.red)
                        .cornerRadius(12)
                }
                
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        vm.showDesiredSalaryInput = false
                    }
                } label: {
                    Text("Save")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundStyle(.white)
                        .cornerRadius(12)
                }
            }
            .padding(.horizontal)
        }
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
        )
        .padding(.horizontal, 24)
        .transition(.scale.combined(with: .opacity))

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
        .font(.title)
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
