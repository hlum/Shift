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
    @Environment(\.modelContext) private var modelContext
    var body: some View {
        
        VStack {
            FSCalendarView(
                selectedDate: $vm.selectedDate,
                needToUpdateUI: $vm.needToUpdateUI
            )
            .frame(maxWidth: .infinity)


            
            VStack {
                selectedDateHeader(selectedDate: vm.selectedDate)
                
                List {
                    ForEach(vm.shifts) { shift in
                        ShiftSubView(shift: shift)
                            .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                Button {
                                    vm.deleteShift(shift)
                                } label: {
                                    Image(systemName: "trash")
                                        .tint(.red)
                                }

                            }
                    }
                    Button {
                        vm.showAddShiftView.toggle()
//                        let mockrepo = MockShiftRepository()
//                        let mockuse = ShiftUseCase(shiftRepository: mockrepo)
//                        let shift = try? mockuse.fetchShifts().first!
//                        
//                        vm.addShift(shift!)
                    } label: {
                        Text("+ Add shift")
                            .font(.headline)
                            .foregroundStyle(.blue)
                    }

                }
                

            }
            .listStyle(.plain)
            .frame(maxWidth: .infinity)
            .frame(height: UIScreen.main.bounds.height * 0.4)
            
        }
        .fullScreenCover(isPresented: $vm.showAddShiftView) {
            // On Dismiss
            vm.fetchShifts(for: vm.selectedDate)
            vm.updateUI()
        } content: {
//#error("Start from here...")
            let repo = SwiftDataShiftRepo(context: modelContext)
            let useCase = ShiftUseCase(shiftRepository: repo)
            AddShiftView(vm: .init(shiftUseCase: useCase), selectedDate: $vm.selectedDate)
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


struct ShiftSubView: View {
    let shift: Shift
    var body: some View {
        HStack {
            VStack {
                Text(shift.startTime.formatted(.dateTime.hour().minute()))
                Text(shift.endTime.formatted(.dateTime.hour().minute()))
            }
            
            Rectangle()
                .frame(width: 1)
                .frame(maxHeight: .infinity)
                .foregroundStyle(shift.company.color.color)
            
            
            Text(shift.name)
                .font(.headline)
            
            Spacer()
            
        }
        .frame(height: 50)
    }
}


#Preview {
    CalendarView(vm: CalendarViewModel.preview())
        .environment(\.locale, Locale(identifier: "ja_JP"))
        .modelContainer(for: Shift.self, inMemory: true)
}
