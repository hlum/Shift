//
//  AddNewCompanyView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import SwiftUI
import SwiftData

final class AddNewCompanyViewModel: ObservableObject {
    private var companyUseCase: CompanyUseCase
    
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
    @Published var lateSalary:Int? = nil
    @Published var lateSalaryStartTime: Date? = Date()
    @Published var lateSalaryEndTime: Date? = Date()
    @Published var paymentType: PaymentType = .hourly

    @Published var baseWorkHours: Double? = nil
    
    
    @Published var showSettlementDatePicker: Bool = false
    @Published var showPayDayPicker: Bool = false
    @Published var showPaymentTypePicker: Bool = false
    
    
    init(companyUseCase: CompanyUseCase) {
        self.companyUseCase = companyUseCase
    }
    
    
    
    func addNewCompany() {
        guard !companyName.isEmpty else {
            // Show alert
            return
        }
        
        
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
        
        companyUseCase.addCompany(newCompany)
    }
}

// MARK: AddNewCompanyView
struct AddNewCompanyView: View {
    @StateObject private var vm: AddNewCompanyViewModel
    @Environment(\.dismiss) var dismiss
    
    init(companyUseCase: CompanyUseCase) {
        _vm = StateObject(wrappedValue: AddNewCompanyViewModel(companyUseCase: companyUseCase))
    }
    var body: some View {
        ZStack {
            Form {
                Section {

                    LabeledContent("Company Name") {
                        TextField("required", text: $vm.companyName)
                    }
                    colorSelection
                }
                
                Section {
                    settlementDateSelectionBtn
                    
                    payDaySelection


                }
                
                
                Section("Salary Information") {
                    NavigationLink {
                        SalarySettingView(
                            showPaymentTypePicker: $vm.showPaymentTypePicker,
                            baseSalary: $vm.baseSalary,
                            transportationExpense: $vm.transportationExpense,
                            holidaySalary: $vm.holidaySalary, baseWorkHours: $vm.baseWorkHours,
                            overtimeSalary: $vm.overtimeSalary,
                            lateSalary: $vm.lateSalary,
                            lateSalaryStartTime: $vm.lateSalaryStartTime,
                            lateSalaryEndTime: $vm.lateSalaryEndTime,
                            paymentType: $vm.paymentType
                        )
                    } label: {
                        HStack {
                            Text("Base salary").foregroundStyle(.gray)
                            Text("\(vm.baseSalary)")
                        }
                    }

                }
            }
        }
        .overlay(alignment: .bottom, content: {
                Button {
                    vm.addNewCompany()
                    dismiss.callAsFunction()
                } label: {
                    Text("Add New Company")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .frame(height: 55)
                        .background(.blue)
                        .cornerRadius(10)
                        .padding(.horizontal)
                        .foregroundStyle(.white)
                }
                
                
                if vm.showSettlementDatePicker {
                    SettlementDatePickerView(selection: $vm.settlementDate, isShowing: $vm.showSettlementDatePicker)
                }
        })
        .foregroundStyle(.black)
        .navigationTitle("Payment date")
        .navigationBarTitleDisplayMode(.inline)

    }
}


extension AddNewCompanyView {
    
    private var settlementDateSelectionBtn: some View {
        Button {
            vm.showSettlementDatePicker = true
        } label: {
            HStack {
                Text("Settlement Day")
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
                Text("Paid at").foregroundStyle(.gray)
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

                        Text(colorName.rawValue)
                        
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
                    Text("Color")
                    Spacer()
                    Circle()
                        .foregroundStyle(vm.selectedColor.color)
                        .frame(height: 10)
                    Text(vm.selectedColor.rawValue)
                    
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
                            Text("Salary")
                                .foregroundStyle(.gray)
                            
                            Spacer()
                            
                            Button {
                                showPaymentTypePicker.toggle()
                            } label: {
                                Text(paymentType.rawValue)
                                    .foregroundStyle(.black)
                            }
                            
                            Rectangle()
                                .frame(width: 1, height: 20)
                            
                            TextField("Base Salary", text: Binding(
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
                            Text("Transport Expense")
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
                            Text("Holiday Salary")
                                .foregroundStyle(.gray)
                            Spacer()
                            
                            TextField("Holiday Salary", text: Binding(
                                get: {
                                    holidaySalary != nil ? String(holidaySalary!)
                                    : "None"
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
                                    Text("Late Night Salary")
                                        .foregroundStyle(.gray)
                                    
                                    Text("\(lateSalary != nil ? String("\(lateSalary!)") : "none")")
                                }
                            }
                            
                            
                            NavigationLink {
                                Text("")
                                OverTimeSalaryView(
                                    baseWorkHours: $baseWorkHours,
                                    overTimePayRate: $overtimeSalary
                                )
                            } label: {
                                HStack {
                                    Text("Overtime Salary")
                                        .foregroundStyle(.gray)
                                    
                                    Text("\(overtimeSalary != nil ? String("\(overtimeSalary!)") : "none")")
                                    
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
            Toggle("Late Night Salary", isOn: Binding(
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
                        Text("Late Night Rate")
                            .foregroundStyle(.gray)
                        Spacer()
                        TextField("Late Night Rate", text:Binding(
                            get: { lateSalary != nil ? "\(lateSalary!)" : "none" },
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
                    
                    DatePicker("Start Time", selection: Binding(
                        get: { lateSalaryStartTime ?? Date() },
                        set: { newValue in
                            lateSalaryStartTime = newValue
                        }
                    ), displayedComponents: .hourAndMinute)
                    
                    DatePicker("End Time", selection: Binding(
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
                Toggle("Has overtime salary", isOn: Binding(
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
                                Text("Applied when")
                                    .foregroundStyle(.gray)
                                Text("\(String(format: "%.2f", baseWorkHours ?? 0))h and above")
                                    .foregroundStyle(.black)
                            }
                        }
                        
                        
                        HStack {
                            Text("Over Time Rate")
                            TextField("Over Time Rate", text: Binding(
                                get: { overTimePayRate != nil ? String(overTimePayRate!) : "None" },
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
                    Text("Close")
                        .padding(.horizontal, 16)
                }
            }
            
            Picker(selection: $selection, label: Text("")) {
                ForEach(1...24, id: \.self) {
                    Text("\($0)h")
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
                        Text("Paid at")
                            .foregroundStyle(.gray)
                        Text(payTiming.displayString)
                        Text(payDay.displayString)
                    }
                }
                
                
                Toggle(isOn: $holidayPayDayChange) {
                    Text("If pay day is holiday, it would change")
                }
                
                if holidayPayDayChange {
                    Section {
                        Button {
                            holidayPayEarly = true
                        } label: {
                            HStack {
                                Text("Early Pay")
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
                                Text("Late Pay")
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
                    Text("Close")
                        .padding(.horizontal, 16)
                }
            }
            
            Picker(selection: $selection, label: Text("")) {
                ForEach((PaymentType.allCases), id: \.self) {
                    Text("\($0)")
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
                    Text("End of Month")
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


//#Preview {
//    LateNightPayView(lateSalary: .constant(1000), lateSalaryStartTime: .constant(nil), lateSalaryEndTime: .constant(nil))
//}


//#Preview {
//    OverTimeSalaryView(baseWorkHours: .constant(8), overTimePayRate: .constant(1400))
//}

#Preview {
    NavigationStack {
        AddNewCompanyView(companyUseCase: CompanyUseCase(companyRepository: MockCompanyRepository()))
    }
}
