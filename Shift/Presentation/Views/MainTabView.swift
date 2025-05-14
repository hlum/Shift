//
//  MainTabView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import SwiftUI
import SwiftData

@MainActor
struct MainTabView: View {
    @Environment(\.container) private var container
    
    var body: some View {
        NavigationStack {
            TabView {
                CalendarView(shiftUseCase: container.shiftUseCase)
                    .tabItem {
                        Image(systemName: "calendar")
                    }
                    .tag(0)
                
                SalaryView(shiftUseCase: container.shiftUseCase, holidayUseCase: container.holidayUseCase)
                    .tabItem {
                        Image(systemName: "dollarsign")
                    }
                    .tag(1)
                
                SettingView()
                    .tabItem {
                        Image(systemName: "gear")
                    }
                    .tag(2)
            }
        }
    }
}

#Preview {
    MainTabView()
        .injectDependencies(DependencyContainer(
            modelContainer: try! ModelContainer(for: Schema([Company.self, Shift.self]))
        ))
}
