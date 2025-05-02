//
//  Item.swift
//  Shift
//
//  Created by cmStudent on 2025/05/02.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
