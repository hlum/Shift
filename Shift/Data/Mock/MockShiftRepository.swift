//
//  MockShiftRepository.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData

final class MockShiftRepository: ShiftRepository {
    
    func fetchShifts() throws -> [Shift] {
        return [
            .init(id: UUID().uuidString, name: "1", startTime: Date(), endTime: Date()),
            .init(id: UUID().uuidString, name: "2", startTime: Date(), endTime: Date())
        ]
    }
    
    func addShift(_ shift: Shift) throws { }
    
    func updateShift(_ shift: Shift) throws { }
    
    func deleteShift(_ shift: Shift) throws { }
    
    
}
