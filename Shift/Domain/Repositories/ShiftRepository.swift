//
//  ShiftRepository.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData

protocol ShiftRepository {
    func fetchShifts() throws -> [Shift]
    func addShift(_ shift: Shift) throws
    func updateShift(_ shift: Shift) throws
    func deleteShift(_ shift: Shift) throws
}
