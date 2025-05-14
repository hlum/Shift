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
}


class MockShiftUseCase: ShiftUseCase {
    init() {
        super.init(shiftRepository: MockShiftRepository())
    }
}
