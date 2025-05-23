//
//  ShiftUseCase.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData

class ShiftUseCase {
    private let shiftRepository: ShiftRepository
    
    init(shiftRepository: ShiftRepository) {
        self.shiftRepository = shiftRepository
    }
    
    
    func fetchShifts(
        descriptor: FetchDescriptor<Shift> = FetchDescriptor<Shift>()
    ) async throws -> [Shift] {
        return try await shiftRepository
            .fetchShifts(
                descriptor: descriptor
            )
    }
    
    
    func addShift(_ shift: Shift) async throws {
        try await shiftRepository.addShift(shift)
    }
    
    
    func updateShift(_ shift: Shift) async throws {
        try await shiftRepository.updateShift(shift)
    }
    
    
    func deleteShift(_ shift: Shift) async throws {
        try await shiftRepository.deleteShift(shift)
    }
    
    
    func getLastMonthShiftBeforeSettlementDate(settlementDate: SettlementDate, currentDate: Date) async throws -> [Shift] {
        
        let settlementDateForLastMonth = getSettlementDateOfLastMonth(settlementDate: settlementDate, currentDate: currentDate)
        let startOfLastMonth = settlementDateForLastMonth.startOfMonth()
        
        let predicate = #Predicate<Shift> { shift in
            shift.startTime >= startOfLastMonth && shift.startTime < settlementDateForLastMonth
        }
        let descriptor = FetchDescriptor<Shift>(predicate: predicate)
        
        return try await self.fetchShifts(descriptor: descriptor)
        
    }
    
    private func getSettlementDateOfLastMonth(settlementDate: SettlementDate, currentDate: Date) -> Date {
        let comp = Calendar.current.dateComponents([.year,.month], from: currentDate)
        let settlementDateForCurrentMonth = settlementDate.toDate(forMonth: comp.month!, year: comp.year!)!
        return Calendar.current.date(byAdding: .month, value: -1, to: settlementDateForCurrentMonth)!
    }
    
    
    func getShiftsWithDifferentMonthsAndCompany(from shifts: [Shift]) -> [Shift] {
        guard !shifts.isEmpty else {
            Logger.standard.warning("There is no shifts")
            return []
        }
        var seenMonthsCompany = Set<String>()

        var result: [Shift] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM" // Use year and month to handle multiple years

        for shift in shifts {
            let monthKey = formatter.string(from: shift.startTime)
            let companyName = shift.company.name
            let monthKeyCompany = "\(companyName)-\(monthKey)"
            
            
            if !seenMonthsCompany.contains(monthKeyCompany) {
                seenMonthsCompany.insert(monthKeyCompany)
                result.append(shift)
            }
        }
        return result
    }

}


class MockShiftUseCase: ShiftUseCase {
    init() {
        super.init(shiftRepository: MockShiftRepository())
    }
}
