//
//  MockCompanyRepository.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import Foundation

import SwiftData

final class MockCompanyRepository: CompanyRepository {
    
    private var companies: [Company] = [
        Company(
           name: "Test2Company",
           color: .blue,
           endDate: .endOfMonth,
           payDay: PayDay(
            payDay: .day(15),
            payTiming: .nextMonth,
               holidayPayDayChange: false,
               holidayPayEarly: false
           ) ,
           salary: Salary(
               baseSalary: 1400,
               transportationExpense: 360,
               holidaySalary: 1400,
               overtimeSalary: OverTimeSetting(baseWorkHours: 8, overtimePayRate: 1400),
               lateSalary: LateSalary(
                lateSalary: 1400,
                startTime: Date(),
                endTime: Date()
               ),
               paymentType: .hourly
           )
       ), Company(
        name: "Test2Company",
        color: .blue,
        endDate: .endOfMonth,
        payDay: PayDay(
            payDay: .endOfMonth,
            payTiming: .currentMonth,
            holidayPayDayChange: false,
            holidayPayEarly: false
        ) ,
        salary: Salary(
            baseSalary: 1400,
            transportationExpense: 360,
            holidaySalary: 1400,
            overtimeSalary: OverTimeSetting(baseWorkHours: 8, overtimePayRate: 1400),
            lateSalary: LateSalary(
                lateSalary: 1400,
                startTime: Date(),
                endTime: Date()
               ),
            paymentType: .oneDay
        )
    )
    ]
    
    func fetchCompanies(descriptor: FetchDescriptor<Company>) throws -> [Company] {
        return companies
    }
    
    func addCompany(_ company: Company) {
        companies.append(company)
    }
    
    func updateCompany(_ company: Company) throws {
        guard let index = companies.firstIndex(where: {company.id == $0.id}) else { return }
        companies[index] = company
    }
    
    func deleteCompany(_ company: Company) throws {
        guard let index = companies.firstIndex(where: {company.id == $0.id}) else { return }
        companies.remove(at: index)
    }
    
    
}
