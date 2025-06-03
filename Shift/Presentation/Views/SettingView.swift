//
//  SettingView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import SwiftUI
import SwiftData

@MainActor
struct SettingView: View {
    @Environment(\.container) private var container
    
    var body: some View {
        Form {
            Section {
                NavigationLink {
                    CompanyListView(companyUseCase: container.companyUseCase)
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
            .injectDependencies(DependencyContainer(
                modelContainer: try! ModelContainer(for: Schema([Company.self, Shift.self]))
            ))
    }
}
