//
//  CompanyUseCase.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import Foundation
import SwiftData

final class CompanyUseCase {
    private let companyRepository: CompanyRepository
    
    init(companyRepository: CompanyRepository) {
        self.companyRepository = companyRepository
    }
    
    
    func getCompanies(descriptor: FetchDescriptor<Company> = FetchDescriptor<Company>()) -> [Company] {
        do {
            let companies = try companyRepository.fetchCompanies(descriptor: descriptor)
            return companies
        } catch {
            print(error.localizedDescription)
            return []
        }
    }
    
    
}
