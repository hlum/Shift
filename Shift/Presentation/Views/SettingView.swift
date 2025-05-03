//
//  SettingView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import SwiftUI

struct SettingView: View {
    @Environment(\.modelContext) var modelContext
    var body: some View {
        Form {
            Section {
                NavigationLink {
                    let companyUseCase = CompanyUseCase(companyRepository: SwiftDataCompanyRepo(context: modelContext))
                    CompanyListView(vm: CompanyListViewModel(companyUseCase: companyUseCase))
                } label: {
                    Text("Company")
                }
            } header: {
                Text("Company List")
            }

        }
    }
}

#Preview {
    NavigationStack {
        SettingView()
    }
}
