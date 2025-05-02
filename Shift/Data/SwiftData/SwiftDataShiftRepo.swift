//
//  SwiftDataShiftRepo.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData

final class SwiftDataShiftRepo: ShiftRepository {
    private let context: ModelContext
    
    init(context: ModelContext) {
        self.context = context
    }
    
    
    
    func fetchShifts() throws -> [Shift] {
        let shiftObjects = try context.fetch(FetchDescriptor<Shift>())
        return shiftObjects.map {
            Shift(
                id: $0.id,
                name: $0.name,
                startTime: $0.startTime,
                endTime: $0.endTime
            )
        }
    }
    
    
    
    func addShift(_ shift: Shift) throws {
        context.insert(shift)
    }
    
    
    
    func updateShift(_ shift: Shift) throws {
        let id = shift.id // Capture the value
        let descriptor = FetchDescriptor<Shift>(predicate: #Predicate { $0.id == id })
        if let existing = try context.fetch(descriptor).first {
            existing.name = shift.name
            existing.startTime = shift.startTime
            existing.endTime = shift.endTime
        }
    }


    
    func deleteShift(_ shift: Shift) throws {
        context.delete(shift)
        
    }
 
    
    
}
