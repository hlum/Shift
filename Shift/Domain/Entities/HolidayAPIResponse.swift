//
//  Holiday.swift
//  Shift
//
//  Created by cmStudent on 2025/05/13.
//

import Foundation
import SwiftData


struct HolidayAPIResponse: Decodable {
    let name: String
    let dateString: String
    let countryCode: String
    
    enum CodingKeys: String, CodingKey {
        case name, countryCode
        case dateString = "date"
    }
    
    var date: Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: dateString)!
    }
}
