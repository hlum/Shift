//
//  CompanyRepository.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import Foundation
import SwiftData

protocol CompanyRepository {
    func fetchCompanies(descriptor: FetchDescriptor<Company>) throws -> [Company]
    func addCompany(_ company: Company)
    func updateCompany(_ company: Company) throws
    func deleteCompany(_ company: Company) throws
}
