//
//  CompanyRepository.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import Foundation
import SwiftData

protocol CompanyRepository {
    func fetchCompanies(descriptor: FetchDescriptor<Company>) async throws -> [Company]
    func addCompany(_ company: Company) async
    func updateCompany(_ company: Company) async throws
    func deleteCompany(_ company: Company) async throws
}
