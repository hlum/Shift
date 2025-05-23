//
//  AddNewCompanyView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import SwiftUI
import SwiftData

final class AddNewCompanyViewModel: ObservableObject {
    private var companyUseCase: CompanyUseCaseProtocol
    
    @Published var companyName: String = ""
    @Published var selectedColor: ColorName = .blue
    @Published var settlementDate: SettlementDate = .endOfMonth
    @Published var payDay: PayDayType = .day(15)
    @Published var payTiming: PayTiming = .nextMonth
    @Published var holidayPayDayChange: Bool = false
    @Published var holidayPayEarly: Bool = false
    
    @Published var baseSalary: Int = 1000
    @Published var transportationExpense: Int = 0
    @Published var holidaySalary: Int? = nil
    @Published var overtimeSalary: Int? = nil
    @Published var lateSalary: Int? = nil
    @Published var lateSalaryStartTime: Date? = Date()
    @Published var lateSalaryEndTime: Date? = Date()
    @Published var paymentType: PaymentType = .hourly
    @Published var baseWorkHours: Double? = nil
    
    @Published var showSettlementDatePicker: Bool = false
    @Published var showPayDayPicker: Bool = false
    @Published var showPaymentTypePicker: Bool = false
    
    @Published var error: Error?
    @Published var isLoading: Bool = false
    
    init(companyUseCase: CompanyUseCaseProtocol) {
        self.companyUseCase = companyUseCase
    }
    
    var isValid: Bool {
        !companyName.isEmpty &&
        baseSalary > 0 &&
        transportationExpense >= 0 &&
        (lateSalary == nil || (lateSalaryStartTime != nil && lateSalaryEndTime != nil))
    }
    
    func addNewCompany() async {
        guard isValid else {
            error = ValidationError.invalidInput
            return
        }
        
        isLoading = true
        error = nil
        
        let salary = Salary(
            baseSalary: baseSalary,
            transportationExpense: transportationExpense,
            holidaySalary: holidaySalary,
            overtimeSalary: baseWorkHours == nil && overtimeSalary == nil ? nil : OverTimeSetting(
                baseWorkHours: baseWorkHours!,
                overtimePayRate: overtimeSalary!
            ),
            lateSalary: LateSalary(
                lateSalary: lateSalary,
                startTime: lateSalaryStartTime,
                endTime: lateSalaryEndTime
            ),
            paymentType: paymentType
        )
        
        let newCompany = Company(
            name: companyName,
            color: selectedColor,
            endDate: settlementDate,
            payDay: PayDay(
                payDay: payDay,
                payTiming: payTiming,
                holidayPayDayChange: holidayPayDayChange,
                holidayPayEarly: holidayPayEarly
            ),
            salary: salary
        )
        
        await companyUseCase.addCompany(newCompany)
        isLoading = false
    }
    
    func updateUseCase(_ newUseCase: CompanyUseCase) {
        self.companyUseCase = newUseCase
    }
}

enum ValidationError: LocalizedError {
    case invalidInput
    
    var errorDescription: String? {
        switch self {
        case .invalidInput:
            return NSLocalizedString("Please check your input values. All required fields must be filled correctly.", comment: "")
        }
    }
}

// MARK: AddNewCompanyView
@MainActor
struct AddNewCompanyView: View {
    @StateObject private var vm: AddNewCompanyViewModel
    @Environment(\.dismiss) var dismiss
    @Environment(\.container) private var container
    
    init(companyUseCase: CompanyUseCaseProtocol = MockCompanyUseCase()) {
        // Initialize with a temporary view model that will be updated when the view appears
        _vm = StateObject(wrappedValue: AddNewCompanyViewModel(companyUseCase: companyUseCase))
    }
    
    var body: some View {
        ZStack {
            Form {
                Section {
                    LabeledContent(NSLocalizedString("Company Name", comment: "")) {
                        TextField(NSLocalizedString("required", comment: ""), text: $vm.companyName)
                    }
                    colorSelection
                }
                
                Section {
                    settlementDateSelectionBtn
                    payDaySelection
                }
                
                Section(NSLocalizedString("Salary Information", comment: "")) {
                    NavigationLink {
                        SalarySettingView(
                            showPaymentTypePicker: $vm.showPaymentTypePicker,
                            baseSalary: $vm.baseSalary,
                            transportationExpense: $vm.transportationExpense,
                            holidaySalary: $vm.holidaySalary,
                            baseWorkHours: $vm.baseWorkHours,
                            overtimeSalary: $vm.overtimeSalary,
                            lateSalary: $vm.lateSalary,
                            lateSalaryStartTime: $vm.lateSalaryStartTime,
                            lateSalaryEndTime: $vm.lateSalaryEndTime,
                            paymentType: $vm.paymentType
                        )
                    } label: {
                        HStack {
                            Text(NSLocalizedString("Base salary", comment: ""))
                                .foregroundStyle(.gray)
                            Text("\(vm.baseSalary)")
                        }
                    }
                }
            }
        }
        .overlay(alignment: .bottom, content: {
            HStack {
                Button {
                    dismiss.callAsFunction()
                } label: {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundStyle(.red)
                        .padding(10)
                }
                
                Button {
                    Task {
                        await vm.addNewCompany()
                        dismiss.callAsFunction()
                    }
                } label: {
                    Text(NSLocalizedString("Add New Company", comment: ""))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(.blue)
                        .cornerRadius(10)
                        .foregroundStyle(.white)
                }
            }
            .padding(.horizontal)
            
            if vm.showSettlementDatePicker {
                SettlementDatePickerView(selection: $vm.settlementDate, isShowing: $vm.showSettlementDatePicker)
            }
        })
        .foregroundStyle(.black)
        .navigationTitle("Payment date")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // Update the view model with the real use case when the view appears
            if let realUseCase = container.companyUseCase as? CompanyUseCase {
                vm.updateUseCase(realUseCase)
            }
        }
    }
}

extension AddNewCompanyView {
    
    private var settlementDateSelectionBtn: some View {
        Button {
            vm.showSettlementDatePicker = true
        } label: {
            HStack {
                Text(NSLocalizedString("Settlement Day", comment: ""))
                    .foregroundStyle(.gray)
                Text("\(vm.settlementDate.displayString)")
            }
        }
    }
    
    private var payDaySelection: some View {
        NavigationLink {
            PayDateSubView(
                showPayDayPicker: $vm.showPayDayPicker,
                payTiming: $vm.payTiming,
                payDay: $vm.payDay,
                holidayPayDayChange: $vm.holidayPayDayChange,
                holidayPayEarly: $vm.holidayPayEarly
            )
        } label: {
            HStack {
                Text(NSLocalizedString("Paid at", comment: ""))
                    .foregroundStyle(.gray)
                Text(vm.payTiming.displayString)
                Text(vm.payDay.displayString)
            }
        }
    }
    
    private var colorSelection: some View {
        NavigationLink {
            List(ColorName.allCases, id: \.self) { colorName in
                Button {
                    vm.selectedColor = colorName
                } label: {
                    HStack {
                        Circle()
                            .foregroundStyle(colorName.color)
                            .frame(height: 10)

                        Text(colorName.disPlayName)
                        
                        Spacer()
                        
                        if colorName == vm.selectedColor {
                            Image(systemName: "checkmark")
                                .foregroundStyle(.green)
                        }
                    }
                }
            }
            .foregroundStyle(.black)

        } label: {
                HStack {
                    Text(NSLocalizedString("Color", comment: ""))
                    Spacer()
                    Circle()
                        .foregroundStyle(vm.selectedColor.color)
                        .frame(height: 10)
                    Text(vm.selectedColor.disPlayName)
                    
                }
        }
    }
}


// MARK: SalarySettingView
struct SalarySettingView: View {
    @Binding var showPaymentTypePicker: Bool
    
    @Binding var baseSalary: Int
    @Binding var transportationExpense: Int
    @Binding var holidaySalary: Int?
    
    @Binding var baseWorkHours: Double?
    @Binding var overtimeSalary: Int?
    
    @Binding var lateSalary:Int?
    @Binding var lateSalaryStartTime: Date?
    @Binding var lateSalaryEndTime: Date?
    @Binding var paymentType: PaymentType
    var body: some View {
        ZStack {
            VStack{
                Form {
                    Section {
                        HStack {
                            Text(NSLocalizedString("Salary", comment: ""))
                                .foregroundStyle(.gray)
                            
                            Spacer()
                            
                            Button {
                                showPaymentTypePicker.toggle()
                            } label: {
                                Text(NSLocalizedString(paymentType.rawValue, comment: ""))
                                    .foregroundStyle(.black)
                            }
                            
                            Rectangle()
                                .frame(width: 1, height: 20)
                            
                            TextField(NSLocalizedString("Base Salary",comment: ""), text: Binding(
                                get: { String("\(baseSalary)") },
                                set: { newValue in
                                    if let intValue = Int(newValue) {
                                        baseSalary = intValue
                                    } else if newValue.isEmpty {
                                        baseSalary = 1000 // or whatever default you want
                                    }
                                }
                            ))
                            .keyboardType(.numberPad)
                            
                            Spacer()

                        }
                    }
                    
                    Section {
                        HStack {
                            Text(NSLocalizedString("Transport Expense", comment: ""))
                                .foregroundStyle(.gray)
                            Spacer()
                            
                            TextField("", text: Binding(
                                get: { String("\(transportationExpense)") },
                                set: { newValue in
                                    if let intValue = Int(newValue) {
                                        transportationExpense = intValue
                                    } else if newValue.isEmpty {
                                        transportationExpense = 0
                                    }
                                }))
                            .keyboardType(.numberPad)

                        }
                        
                        HStack {
                            Text(NSLocalizedString("Holiday Salary", comment: ""))
                                .foregroundStyle(.gray)
                            Spacer()
                            
                            TextField(NSLocalizedString("Holiday Salary", comment: ""), text: Binding(
                                get: {
                                    holidaySalary != nil ? String(holidaySalary!)
                                    : NSLocalizedString("None", comment: "")
                                },
                                set: { newValue in
                                    if let intValue = Int(newValue) {
                                        holidaySalary = intValue
                                    } else if newValue.isEmpty {
                                        holidaySalary = nil
                                    } else {
                                        holidaySalary = nil
                                    }
                                }
                            ))
                        }
                        
                        
                        if paymentType != PaymentType.oneDay {
                            NavigationLink {
                                LateNightPayView(
                                    lateSalary: $lateSalary,
                                    lateSalaryStartTime: $lateSalaryStartTime,
                                    lateSalaryEndTime: $lateSalaryEndTime
                                )
                            } label: {
                                HStack {
                                    Text(NSLocalizedString("Late Night Salary", comment: ""))
                                        .foregroundStyle(.gray)
                                    
                                    Text("\(lateSalary != nil ? String("\(lateSalary!)") : NSLocalizedString("None", comment: ""))")
                                }
                            }
                            
                            
                            NavigationLink {
                                OverTimeSalaryView(
                                    baseWorkHours: $baseWorkHours,
                                    overTimePayRate: $overtimeSalary
                                )
                            } label: {
                                HStack {
                                    Text(NSLocalizedString("Overtime Salary", comment: ""))
                                        .foregroundStyle(.gray)
                                    
                                    Text("\(overtimeSalary != nil ? String("\(overtimeSalary!)") : NSLocalizedString("None", comment: ""))")
                                    
                                }
                            }


                        }
                    }
                }
            }
            
            PaymentTypePickerView(selection: $paymentType, isShowing: $showPaymentTypePicker)
                .offset(y: showPaymentTypePicker ? 0 : UIScreen.main.bounds.height)
        }
    }
}


// MARK: LateNightPayView
struct LateNightPayView: View {
    @State var hasLateNightSalary: Bool = false
    @Binding var lateSalary:Int?
    @Binding var lateSalaryStartTime: Date?
    @Binding var lateSalaryEndTime: Date?

    var body: some View {
        Form {
            Toggle(NSLocalizedString("Late Night Salary", comment: ""), isOn: Binding(
                get:{ hasLateNightSalary } ,
                set: { newValue in
                    
                    if !newValue {
                        lateSalary = nil
                        lateSalaryStartTime = nil
                        lateSalaryEndTime = nil
                    }
                    hasLateNightSalary = newValue
                    
                }))
            
            
            if hasLateNightSalary {
                Section {
                    HStack {
                        Text(NSLocalizedString("Late Night Rate", comment: ""))
                            .foregroundStyle(.gray)
                        Spacer()
                        TextField("Late Night Rate", text:Binding(
                            get: { lateSalary != nil ? "\(lateSalary!)" : NSLocalizedString("None", comment: "") },
                            set: { newValue in
                                if let intValue = Int(newValue) {
                                    lateSalary = intValue
                                } else if newValue.isEmpty {
                                    lateSalary = nil
                                } else {
                                    lateSalary = nil
                                }
                            }))
                        .keyboardType(.decimalPad)
                    }
                    
                    DatePicker(NSLocalizedString("Start Time", comment: ""), selection: Binding(
                        get: { lateSalaryStartTime ?? Date() },
                        set: { newValue in
                            lateSalaryStartTime = newValue
                        }
                    ), displayedComponents: .hourAndMinute)
                    
                    DatePicker(NSLocalizedString("End Time", comment: ""), selection: Binding(
                        get: { lateSalaryEndTime ?? Date() },
                        set: { newValue in lateSalaryEndTime = newValue }
                    ), displayedComponents: .hourAndMinute)
                }
            }
        }
    }
}


// MARK: OverTimeSalaryView
struct OverTimeSalaryView: View {
    @State var hasOverTimeSalary: Bool = false
    @State var showBaseWorkHourPicker: Bool = false
    @Binding var baseWorkHours: Double?
    @Binding var overTimePayRate: Int?
    var body: some View {
        ZStack {
            Form {
                Toggle(NSLocalizedString("Has overtime salary",comment:""), isOn: Binding(
                    get:{ hasOverTimeSalary } ,
                    set: { newValue in
                        
                        if !newValue {
                            baseWorkHours = nil
                            overTimePayRate = nil
                        }
                        hasOverTimeSalary = newValue
                        
                    }))
                
                if hasOverTimeSalary {
                    Section {
                        Button {
                            showBaseWorkHourPicker.toggle()
                        } label: {
                            HStack {
                                Text(NSLocalizedString("Applied when", comment: ""))
                                    .foregroundStyle(.gray)
                                let hours = baseWorkHours ?? 0
                                Text(String(format: NSLocalizedString("work_hours_and_above", comment: ""), hours))
                                    .foregroundStyle(.black)
                            }
                        }
                        
                        
                        HStack {
                            Text(NSLocalizedString("Over Time Rate", comment: ""))
                            TextField(NSLocalizedString("Over Time Rate", comment: ""), text: Binding(
                                get: { overTimePayRate != nil ? String(overTimePayRate!) : NSLocalizedString("None", comment: "") },
                                set: { newValue in
                                    if let intValue = Int(newValue) {
                                        overTimePayRate = intValue
                                    } else if newValue.isEmpty {
                                        overTimePayRate = 0
                                    } else {
                                        overTimePayRate = 0
                                    }
                                }))
                        }
                    }
                }
            }
            
            
            BaseWorkHourPickerView(selection: $baseWorkHours, isShowing: $showBaseWorkHourPicker)
                .offset(y: showBaseWorkHourPicker ? 0 : UIScreen.main.bounds.height)

        }
    }
}

// MARK: PaymentType PickerView
struct BaseWorkHourPickerView: View {
    @Binding var selection: Double?
    @Binding var isShowing: Bool
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                self.isShowing = false
            }) {
                HStack {
                    Spacer()
                    Text(NSLocalizedString("Close", comment:""))
                        .padding(.horizontal, 16)
                }
            }
            
            Picker(selection: $selection, label: Text("")) {
                ForEach(1...24, id: \.self) {
                    Text("\($0)" + NSLocalizedString("h", comment: ""))
                        .tag(Double($0))
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 200)
            .labelsHidden()
        }
    }
}


// MARK: PayDateSubView
struct PayDateSubView: View {
    @Binding var showPayDayPicker: Bool
    @Binding var payTiming: PayTiming
    @Binding var payDay: PayDayType
    @Binding var holidayPayDayChange: Bool
    @Binding var holidayPayEarly: Bool
    
    var body: some View {
        ZStack {
            Form {
                                
                Button {
                    showPayDayPicker = true
                } label: {
                    HStack {
                        Text(NSLocalizedString("Paid at", comment: ""))
                            .foregroundStyle(.gray)
                        Text(payTiming.displayString)
                        Text(payDay.displayString)
                    }
                }
                
                
                Toggle(isOn: $holidayPayDayChange) {
                    Text(NSLocalizedString("If pay day is holiday, it would change", comment: ""))
                }
                
                if holidayPayDayChange {
                    Section {
                        Button {
                            holidayPayEarly = true
                        } label: {
                            HStack {
                                Text(NSLocalizedString("Early Pay", comment: ""))
                                Spacer()
                                if holidayPayEarly {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                        
                        Button {
                            holidayPayEarly = false
                        } label: {
                            HStack {
                                Text(NSLocalizedString("Late Pay", comment: ""))
                                Spacer()
                                if !holidayPayEarly {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
            }
            .foregroundStyle(.black)
            
            PayDatePickerView(selectedPayTiming: $payTiming, selectedPayDayType: $payDay, isShowing: $showPayDayPicker)
                .offset(y: showPayDayPicker ? 0 : UIScreen.main.bounds.height)

        }
    }
}

// MARK: PaymentType PickerView
struct PaymentTypePickerView: View {
    @Binding var selection: PaymentType
    @Binding var isShowing: Bool
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                self.isShowing = false
            }) {
                HStack {
                    Spacer()
                    Text(NSLocalizedString("Close",comment:""))
                        .padding(.horizontal, 16)
                }
            }
            
            Picker(selection: $selection, label: Text("")) {
                ForEach((PaymentType.allCases), id: \.self) {
                    Text(NSLocalizedString("\($0)", comment: ""))
                        .tag($0)
                }
            }
            .pickerStyle(.wheel)
            .frame(width: 200)
            .labelsHidden()
        }
    }
}

// MARK: PayDatePickerView
struct PayDatePickerView: View {
    @Binding var selectedPayTiming: PayTiming
    @Binding var selectedPayDayType: PayDayType
    @Binding var isShowing: Bool
    
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                self.isShowing = false
            }) {
                HStack {
                    Spacer()
                    Text("Close")
                        .padding(.horizontal, 16)
                }
            }
            
            HStack {
                // PayTiming Picker (Left)
                Picker(selection: $selectedPayTiming, label: Text("")) {
                    ForEach(PayTiming.allCases, id: \.self) { timing in
                        Text(timing.displayString)
                            .tag(timing)
                    }
                }
                .pickerStyle(.wheel)
                .frame(width: 150)
                .clipped()
                .labelsHidden()
                
                // PayDayType Picker (Right)
                Picker(selection: $selectedPayDayType, label: Text("")) {
                    ForEach(1...30, id: \.self) { day in
                        Text("\(day)")
                            .tag(PayDayType.day(day))
                    }
                    Text(NSLocalizedString("End of Month", comment: ""))
                        .tag(PayDayType.endOfMonth)
                }
                .pickerStyle(.wheel)
                .frame(width: 150)
                .clipped()
                .labelsHidden()
            }
            .frame(height: 180)
        }
    }
}


// MARK: SettlementDatePickerView
struct SettlementDatePickerView: View {
    @Binding var selection: SettlementDate
    @Binding var isShowing: Bool
    var body: some View {
        VStack {
            Spacer()
            Button(action: {
                self.isShowing = false
            }) {
                HStack {
                    Spacer()
                    Text("Close")
                        .padding(.horizontal, 16)
                }
            }
            
            Picker(selection: $selection, label: Text("")) {
                ForEach((1...30), id: \.self) {
                    Text("\($0)")
                        .tag(SettlementDate.day($0))
                }
                Text("End of Month")
                    .tag(SettlementDate.endOfMonth)
            }
            .pickerStyle(.wheel)
            .frame(width: 200)
            .labelsHidden()
        }
    }
}


// MARK: - Mock Company Use Case for Preview


#Preview {
    NavigationStack {
        AddNewCompanyView()
            .injectDependencies(DependencyContainer(
                modelContainer: try! ModelContainer(for: Schema([Company.self, Shift.self]))
            ))
    }
}
