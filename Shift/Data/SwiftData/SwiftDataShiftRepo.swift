//
//  SwiftDataShiftRepo.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData

final actor SwiftDataShiftRepo: ShiftRepository {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    
    
    func fetchShifts(descriptor: FetchDescriptor<Shift>) async throws -> [Shift] {
        return try context.fetch(descriptor)
    }
    
    
    
    func addShift(_ shift: Shift) async throws {
        shift.company.shifts.append(shift)
        context.insert(shift)
        try context.save()
    }
    
    
    
    func updateShift(_ shift: Shift) async throws {
        let id = shift.id // Capture the value
        let descriptor = FetchDescriptor<Shift>(predicate: #Predicate { $0.id == id })
        if let existing = try context.fetch(descriptor).first {
            existing.name = shift.name
            existing.startTime = shift.startTime
            existing.endTime = shift.endTime
            
            // If the company changed
            if existing.company.id != shift.company.id {
                // Remove from old company's shifts
                if let index = existing.company.shifts.firstIndex(where: { $0.id == existing.id }) {
                    existing.company.shifts.remove(at: index)
                }
                // Add to new company's shifts
                shift.company.shifts.append(existing)
                existing.company = shift.company
            }
        }
        try context.save()
    }


    
    func deleteShift(_ shift: Shift) async throws {
        // Remove from company's shifts array
        if let index = shift.company.shifts.firstIndex(where: { $0.id == shift.id }) {
            shift.company.shifts.remove(at: index)
        }
        context.delete(shift)
        try context.save()
    }
    
    
}
