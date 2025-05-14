//
//  AddShiftView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/08.
//

import SwiftUI
import SwiftData

final class AddShiftViewModel: ObservableObject {
    private let shiftUseCase: ShiftUseCase
    
    @Published var company: Company? = nil
    @Published var title: String = ""
    @Published var startTime: Date = Date()
    @Published var endTime: Date = Date()
    @Published var breakDuration: Double = 0
    
    @Published var errorMessage: String?
    
    @Published var showAlert: Bool = false
    
    
    @Published var shouldFocusTitleTextField: Bool = false
    
    
    
    init(shiftUseCase: ShiftUseCase) {
        self.shiftUseCase = shiftUseCase
    }
    
    /// Return true if adding shift is success
    func addShift() -> Bool {
        guard let company else {
            // Show Alert
            errorMessage = "Company is required"
            return false
        }
        
        guard !title.isEmpty else {
            // Show Alert
            errorMessage = "Title is required"
            shouldFocusTitleTextField = true
            return false
        }
        
        let newShift = Shift(name: title, startTime: startTime, breakDuration: breakDuration, endTime: endTime, company: company)
        do {
            try shiftUseCase.addShift(newShift)
            errorMessage = nil
            return true
        } catch {
            print("Error adding shift: \(error.localizedDescription)")
            return false
        }
    }
    
}

struct AddShiftView: View {
    @StateObject var vm: AddShiftViewModel
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedDate: Date
    
    @FocusState var titleTextFieldIsFocused: Bool

    init(shiftUseCase: ShiftUseCase = MockShiftUseCase(), selectedDate: Binding<Date>) {
        _vm = .init(wrappedValue: .init(shiftUseCase: shiftUseCase))
        _selectedDate = selectedDate
    }
    
    // Reference date (e.g., midnight)
    let referenceDate = Calendar.current.startOfDay(for: Date())
    
    var breakDateBinding: Binding<Date> {
        Binding<Date>(
            get: {
                referenceDate.addingTimeInterval(vm.breakDuration * 60)
            },
            set: { newDate in
                vm.breakDuration = newDate.timeIntervalSince(referenceDate) / 60
            }
        )
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    NavigationLink {
                        CompanySelectionView(selectedCompany: $vm.company)
                    } label: {
                        HStack {
                            Text("Company")
                                .foregroundStyle(.gray)
                            Text(vm.company?.name ?? "None")
                        }
                    }
                    
                    
                    TextField("Title", text: $vm.title)
                        .focused($titleTextFieldIsFocused)
                }
                
                
                Section(footer: Text(vm.errorMessage ?? "").foregroundStyle(.red)) {
                    DatePicker("Start Time", selection: $vm.startTime, displayedComponents: [.date,.hourAndMinute])
                    
                    DatePicker("End Time", selection: $vm.endTime, displayedComponents: [.date,.hourAndMinute])
                    
                    DatePicker("Break Time", selection: breakDateBinding, displayedComponents: .hourAndMinute)
                }
                
            }
            .onChange(of: vm.shouldFocusTitleTextField, { _, newValue in
                titleTextFieldIsFocused = newValue
            })
            .alert(isPresented: $vm.showAlert) {
                Alert(title: Text("Do you want to close this window?"), message: Text("If you close this window, it will be lost."),
                      primaryButton: .destructive(Text("OK"),action: {
                    dismiss.callAsFunction()
                }),
                      secondaryButton: .default(Text("Cancel"))
                )
            }
            .overlay(alignment: .bottom) {
                HStack {
                    Button {
                        vm.showAlert.toggle()
                    } label: {
                        Text("Cancel")
                            .font(.headline)
                            .foregroundStyle(.red)
                            .padding(.horizontal)
                    }
                    
                    
                    Button {
                        let shiftAdded = vm.addShift()
                        if shiftAdded {
                            dismiss.callAsFunction()
                            selectedDate = vm.startTime
                        }
                    } label: {
                        Text("Add Shift")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 55)
                            .background(.blue)
                            .cornerRadius(10)
                        
                    }
                }
                .padding(.horizontal)
            }
        }
    }
}


struct CompanySelectionView: View {
    @State private var showAddCompany = false
    @Binding var selectedCompany: Company?
    @Environment(\.container) private var container
    @State private var companies: [Company] = []
    
    var body: some View {
        VStack {
            List(companies) { company in
                Button {
                    selectedCompany = company
                } label: {
                    HStack {
                        Text(company.name)
                        Spacer()
                        if selectedCompany == company {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.blue)
                        }
                    }
                    .foregroundStyle(.black)
                }
            }
            
            Button {
                showAddCompany.toggle()
            } label: {
                Text("Add Company")
                    .foregroundStyle(.white)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(.blue)
                    .cornerRadius(10)
                    .padding(10)
            }
        }
        .fullScreenCover(isPresented: $showAddCompany) {
            NavigationStack {
                AddNewCompanyView(companyUseCase: container.companyUseCase)
            }
        }
        .navigationTitle("Select Company")
        .onAppear {
            fetchCompanies()
        }
    }
    
    private func fetchCompanies() {
        let companies = container.companyUseCase.getCompanies()
        DispatchQueue.main.async {
            self.companies = companies
        }
    }
}

#Preview {
    AddShiftView(selectedDate: .constant(Date()))
        .injectDependencies(DependencyContainer(
            modelContainer: try! ModelContainer(for: Schema([Company.self, Shift.self]))
        ))
}
