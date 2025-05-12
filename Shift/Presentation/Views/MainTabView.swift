//
//  MainTabView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/03.
//

import SwiftUI

struct MainTabView: View {
    @Environment(\.modelContext) var modelContext
    var body: some View {
        NavigationStack {
            TabView {
                let calendarViewModel = CalendarViewModel(
                    shiftUseCase: ShiftUseCase(
                        shiftRepository: SwiftDataShiftRepo(
                            context: modelContext
                        )
                    )
                )
                CalendarView(vm: calendarViewModel)
                    .tabItem {
                        Image(systemName: "calendar")
                    }
                    .tag(0)
                
                
                let salaryViewModel = SalaryViewModel(shiftUseCase: ShiftUseCase(shiftRepository: SwiftDataShiftRepo(context: modelContext)))
                
                SalaryView(vm: salaryViewModel)
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
}
