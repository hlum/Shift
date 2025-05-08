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
    
    private let companyUseCase: CompanyUseCase
    
    init(companyUseCase: CompanyUseCase) {
        self.companyUseCase = companyUseCase
    }
    
    func fetchCompanies() {
        let companies = companyUseCase.getCompanies()
        DispatchQueue.main.async {
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
    @Environment(\.modelContext) var modelContext
    var body: some View {
        VStack {
            List(vm.companies) { company in
                NavigationLink {
                    Text(company.name)
                    Text(company.color.rawValue)
                    Text(company.payDay.payDay.displayString)
                    Text(company.salary.baseSalary.description)
                    Text(company.salary.overtimeSalary?.overtimePayRate.description ?? "")
                } label: {
                    Text(company.name)
                }
            }
        }
        .onAppear {
            vm.fetchCompanies()
        }
        .overlay(alignment: .bottom, content: {
            NavigationLink {
                let repo = SwiftDataCompanyRepo(context: modelContext)
                let useCase = CompanyUseCase(companyRepository: repo)
                AddNewCompanyView(companyUseCase: useCase)
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
        CompanyListView(vm: CompanyListViewModel.preview())
    }
}
