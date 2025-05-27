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
    func getShiftsBetweenLastMonthSettlementPeriod(company: Company, currentDate: Date) async throws -> [Shift]
    func getShiftsWithDifferentSettlementPeriodsAndCompany(from shifts: [Shift]) -> [Shift]
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
    
    
    func getShiftsBetweenLastMonthSettlementPeriod(company: Company, currentDate: Date) async throws -> [Shift] {
        let comp = Calendar.current.dateComponents([.year, .month], from: currentDate)
        let settlementPeriod = company.settleMentDate.settlementPeriod(forMonth: comp.month!, year: comp.year!)
        
        // The start of the last month settlement date.
        let start = Calendar.current.date(byAdding: .month, value: -1, to: settlementPeriod.start)!
        
        // The end of the last month settlement date.
        let end = Calendar.current.date(byAdding: .month, value: -1, to: settlementPeriod.end)!

        let companyId = company.id
        
        let predicate = #Predicate<Shift> { shift in
            return (shift.startTime >= start && shift.startTime <= end) && (shift.company.id == companyId)
        }
        
        let descriptor = FetchDescriptor<Shift>(predicate: predicate)
        
        let results = try await self.fetchShifts(descriptor: descriptor)
        
        return results
        
    }
    
    
    /// return shifts that are different in settlement period and company
    func getShiftsWithDifferentSettlementPeriodsAndCompany(from shifts: [Shift]) -> [Shift] {
        guard !shifts.isEmpty else {
            Logger.warning("There is no shifts", category: .shift)
            return []
        }
        var seenMonthsCompany = Set<String>()
        var result: [Shift] = []
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM" // Use year and month to handle multiple years

        for shift in shifts {
            // Get the month key based on the settlement date's month
            let settlementDate = shift.company.settleMentDate.toDate(
                forMonth: Calendar.current.component(.month, from: shift.startTime),
                year: Calendar.current.component(.year, from: shift.startTime)
            )!
            
            var nextDayOfSettlementDate = Calendar.current.date(byAdding: .day, value: 1, to: settlementDate)!
            nextDayOfSettlementDate = Calendar.current.startOfDay(for: nextDayOfSettlementDate)
            
            // If the shift's start time is after the settlement date, it belongs to the next month's salary
            let monthKey: String
            if shift.startTime > nextDayOfSettlementDate {
                let nextMonth = Calendar.current.date(byAdding: .month, value: 1, to: shift.startTime)!
                monthKey = formatter.string(from: nextMonth)
            } else {
                monthKey = formatter.string(from: shift.startTime)
            }
            
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
