//
//  ContentView.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import SwiftUI
import SwiftData



struct CalendarView: View {
    @StateObject var vm: CalendarViewModel
    var body: some View {
        VStack {
            Button("Add Shift", action: {
                vm.addShift(Shift(id: "121", name: "Test1", startTime: Date(), endTime: Date()))
            })
            ForEach(vm.shifts) { shift in
                Text(shift.name)
            }
        }
    }
}


#Preview {
    CalendarView(vm: CalendarViewModel.preview())
        .modelContainer(for: Shift.self, inMemory: true)
}
