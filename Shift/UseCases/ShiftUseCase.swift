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
    ) throws -> [Shift] {
        return try shiftRepository
            .fetchShifts(
                descriptor: descriptor
            )
    }
    
    
    func addShift(_ shift: Shift) throws {
        try shiftRepository.addShift(shift)
    }
    
    
    func updateShift(_ shift: Shift) throws {
        try shiftRepository.updateShift(shift)
    }
    
    
    func deleteShift(_ shift: Shift) throws {
        try shiftRepository.deleteShift(shift)
    }
}


class MockShiftUseCase: ShiftUseCase {
    init() {
        super.init(shiftRepository: MockShiftRepository())
    }
}
