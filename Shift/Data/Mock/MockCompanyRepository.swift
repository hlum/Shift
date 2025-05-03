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
           id: "test2",
           name: "Test2Company",
           color: .blue,
           endDate: Date(),
           payDay: PayDay(
               payDay: Date().addingTimeInterval(
                   86400
               ),
               holidayPayDayChange: false,
               holidayPayEarly: false
           ) ,
           salary: Salary(
               baseSalary: 1400,
               transportationExpense: 360,
               holidaySalary: 1400,
               lateSalary: LateSalary(
                   salary: 1560,
                   startTime: Date(),
                   endTime: Date()
               ),
               overtimeSalary: 1560
           )
       ), Company(
        id: "test4",
        name: "Test2Company",
        color: .blue,
        endDate: Date(),
        payDay: PayDay(
            payDay: Date().addingTimeInterval(
                86400
            ),
            holidayPayDayChange: false,
            holidayPayEarly: false
        ) ,
        salary: Salary(
            baseSalary: 1400,
            transportationExpense: 360,
            holidaySalary: 1400,
            lateSalary: LateSalary(
                salary: 1560,
                startTime: Date(),
                endTime: Date()
            ),
            overtimeSalary: 1560
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
