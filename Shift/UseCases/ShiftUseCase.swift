//
//  ShiftUseCase.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData


protocol ShiftUseCaseProtocol {
    func fetchShifts(
        descriptor: FetchDescriptor<Shift>?
    ) async throws -> [Shift]
    
    func addShift(_ shift: Shift) async throws
    func updateShift(_ shift: Shift) async throws
    func deleteShift(_ shift: Shift) async throws
    func getLastMonthShiftsBeforeSettlementDate(company: Company, currentDate: Date) async throws -> [Shift]
    func getShiftsWithDifferentMonthsAndCompany(from shifts: [Shift]) -> [Shift]
}

class ShiftUseCase: ShiftUseCaseProtocol {
    private let shiftRepository: ShiftRepository
    
    init(shiftRepository: ShiftRepository) {
        self.shiftRepository = shiftRepository
    }
    
    
    func fetchShifts(descriptor: FetchDescriptor<Shift>?) async throws -> [Shift] {
        return try await shiftRepository.fetchShifts(descriptor: descriptor ?? FetchDescriptor<Shift>())
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
    
    
    func getLastMonthShiftsBeforeSettlementDate(company: Company, currentDate: Date) async throws -> [Shift] {
        
        let settlementDateForLastMonth = getSettlementDateOfLastMonth(settlementDate: company.settleMentDate, currentDate: currentDate)
        
        let startOfLastMonth = settlementDateForLastMonth.startOfMonth()
        
        let companyId = company.id
        
        let predicate = #Predicate<Shift> { shift in
            return (shift.startTime >= startOfLastMonth && shift.startTime <= settlementDateForLastMonth) && (shift.company.id == companyId)
        }
        
        let descriptor = FetchDescriptor<Shift>(predicate: predicate)
        
        let results = try await self.fetchShifts(descriptor: descriptor)
        
        return results
        
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
