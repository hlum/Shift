import Foundation
import SwiftData

@Model
final class Holiday: Identifiable, Equatable {
    @Attribute(.unique) var id: String
    var name: String
    var date: Date
    var countryCode: String
    
    init(id: String = UUID().uuidString, name: String, date: Date, countryCode: String) {
        self.id = id
        self.name = name
        self.date = date
        self.countryCode = countryCode
    }

    init(holidayApiResponse: HolidayAPIResponse) {
        self.id = UUID().uuidString
        self.name = holidayApiResponse.name
        self.date = holidayApiResponse.date
        self.countryCode = holidayApiResponse.countryCode
    }
} 
