//
//  Item.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData

@Model
final class Shift {
    @Attribute(.unique) var id: String = UUID().uuidString
    var name: String
    var startTime: Date
    var endTime: Date
    var company: Company
    
    init(id: String, name: String, startTime: Date, endTime: Date) {
        self.id = id
        self.name = name
        self.startTime = startTime
        self.endTime = endTime
    }
}


