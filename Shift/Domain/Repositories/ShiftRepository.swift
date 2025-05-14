//
//  ShiftRepository.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData

protocol ShiftRepository {
    func fetchShifts(descriptor: FetchDescriptor<Shift>) async throws -> [Shift]
    func addShift(_ shift: Shift) async throws
    func updateShift(_ shift: Shift) async throws
    func deleteShift(_ shift: Shift) async throws
}
