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
    
    
    
    func fetchShifts(descriptor: FetchDescriptor<Shift>) throws -> [Shift] {
        let shiftObjects = try context.fetch(descriptor)
        
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
        let descriptor = FetchDescriptor<Shift>(predicate: #Predicate { $0.id == shift.id })
        
        if let object = try context.fetch(descriptor).first {
            object.name = shift.name
            object.startTime = shift.startTime
            object.endTime = shift.endTime
        }
        
    }
    
    
    
    func deleteShift(_ shift: Shift) throws {
        let descriptor = FetchDescriptor<Shift>(predicate: #Predicate { $0.id == shift.id })
        if let object = try context.fetch(descriptor).first {
            context.delete(object)
        }
    }
 
    
    
}
