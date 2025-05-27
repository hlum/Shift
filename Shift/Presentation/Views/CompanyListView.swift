//
//  CompanyListView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import SwiftUI

final class CompanyListViewModel: ObservableObject {
    @Published var companies: [Company] = []
    @Published var showAddNewCompanySheet: Bool = false
    
    private let companyUseCase: CompanyUseCaseProtocol
    
    init(companyUseCase: CompanyUseCaseProtocol) {
        self.companyUseCase = companyUseCase
    }
    
    func fetchCompanies() async {
        let companies = await companyUseCase.getCompanies(descriptor: nil)
        await MainActor.run {
            self.companies = companies
        }
    }
}

// Preview 用のViewModel
extension CompanyListViewModel {
    static func preview() -> CompanyListViewModel {
        let repo = MockCompanyRepository()
        let useCase = CompanyUseCase(companyRepository: repo)
        let viewModel = CompanyListViewModel(companyUseCase: useCase)
        
        return viewModel
    }
}

struct CompanyListView: View {
    @StateObject var vm: CompanyListViewModel
    @Environment(\.container) var container
    
    
    init(companyUseCase: CompanyUseCaseProtocol = MockCompanyUseCase()) {
        _vm = .init(wrappedValue: .init(companyUseCase: companyUseCase))
    }
    var body: some View {
        VStack {
            List(vm.companies) { company in
                NavigationLink {
                    Text(company.name)
                    Text("Base Salary:" + company.salary.baseSalary.description)
                    Text("Overtime pay rate:" + "\(company.salary.overtimeSalary?.overtimePayRate ?? 0)")
                    Text("Late night pay rate:" + "\(company.salary.lateSalary?.lateSalary ?? 0)")
                    Text("Late night start:" + "\(company.salary.lateSalary?.startTime?.formatted())")
                    Text("Late night end:" + "\(company.salary.lateSalary?.endTime?.formatted())")
                } label: {
                    Text(company.name)
                }
            }
        }
        .task {
            await vm.fetchCompanies()
        }
        .overlay(alignment: .bottom, content: {
            NavigationLink {
                AddNewCompanyView(companyUseCase: container.companyUseCase)
            } label: {
                Text("Add Company")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .frame(height: 55)
                    .background(.blue)
                    .foregroundStyle(.white)
                    .cornerRadius(10)
                    .padding()
            }
        })
        .foregroundStyle(.black)
    }
}

#Preview {
    NavigationStack {
        CompanyListView()
    }
}
