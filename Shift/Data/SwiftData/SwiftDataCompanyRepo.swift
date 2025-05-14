//
//  SwiftDataCompanyRepo.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import Foundation
import SwiftData

final actor SwiftDataCompanyRepo: CompanyRepository {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }

    
    
    func fetchCompanies(descriptor: FetchDescriptor<Company>) async throws -> [Company] {
        return try context.fetch(descriptor)
    }
    
    func addCompany(_ company: Company) async {
        context.insert(company)
    }
    
    func updateCompany(_ company: Company) async throws {
        let id = company.id
        let descriptor = FetchDescriptor<Company>(predicate: #Predicate{ $0.id == id })
        
        if let existing = try context.fetch(descriptor).first {
            existing.name = company.name
            existing.color = company.color
            existing.settleMentDate = company.settleMentDate
            existing.payDay = company.payDay
            existing.salary = company.salary
        }
    }
    
    func deleteCompany(_ company: Company) async throws {
        context.delete(company)
    }
    
    
    
    
}
