//
//  Holiday.swift
//  Shift
//
//  Created by cmStudent on 2025/05/13.
//

import Foundation

struct Holiday: Decodable {
    let name: String
    let dateString: String
    
    enum CodingKeys: String, CodingKey {
        case name
        case dateString = "date"
    }
    
    var date: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        return formatter.date(from: dateString)!
    }
}
