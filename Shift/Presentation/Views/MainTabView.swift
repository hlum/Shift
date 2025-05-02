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
        }
    }
}

#Preview {
    MainTabView()
}
