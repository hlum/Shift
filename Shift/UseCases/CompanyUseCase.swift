//
//  CompanyUseCase.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import Foundation
import SwiftData

protocol CompanyUseCaseProtocol {
    func getCompanies(descriptor: FetchDescriptor<Company>?) async -> [Company]
    func addCompany(_ company: Company) async
}

class CompanyUseCase: CompanyUseCaseProtocol {
    private let companyRepository: CompanyRepository
    
    init(companyRepository: CompanyRepository) {
        self.companyRepository = companyRepository
    }
    
    
    func getCompanies(descriptor: FetchDescriptor<Company>? = nil) async -> [Company] {
        do {
            let companies = try await companyRepository.fetchCompanies(descriptor: descriptor ?? FetchDescriptor<Company>())
            return companies
        } catch {
            Logger.standard.error("Error fetching companies:\(error.localizedDescription)")
            return []
        }
    }
    
    
    func addCompany(_ company: Company) async {
        await companyRepository.addCompany(company)
    }
    
    
}


class MockCompanyUseCase: CompanyUseCaseProtocol {
    let mockCompanyRepo = MockCompanyRepository()
    
    func getCompanies(descriptor: FetchDescriptor<Company>? = nil) async -> [Company] {
        return (try? mockCompanyRepo.fetchCompanies(descriptor: descriptor ?? FetchDescriptor<Company>()))!
    }
    
    func addCompany(_ company: Company) async {
        mockCompanyRepo.addCompany(company)
    }
}
