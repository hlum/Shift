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
            FSCalendarView()
                .frame(maxWidth: .infinity)
            
            VStack {
                selectedDateHeader(selectedDate: Date())
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * 0.4)
            
        }
        
    }
    
    @ViewBuilder
    func selectedDateHeader(selectedDate: Date) -> some View {
        Text(selectedDate.formatted(date: .abbreviated, time: .omitted))
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(height: 30)
            .background(.gray)
        
    }
}


#Preview {
    CalendarView(vm: CalendarViewModel.preview())
        .environment(\.locale, Locale(identifier: "ja_JP"))
        .modelContainer(for: Shift.self, inMemory: true)
}
