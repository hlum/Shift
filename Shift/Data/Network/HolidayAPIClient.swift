import Foundation

enum HolidayAPIError: LocalizedError {
    case invalidURL
    case invalidResponse
    case decodingError(Error)
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "")
        case .invalidResponse:
            return NSLocalizedString("Invalid response from server", comment: "")
        case .decodingError(let error):
            return String(format: NSLocalizedString("Failed to decode response: %@", comment: ""), error.localizedDescription)
        case .networkError(let error):
            return String(format: NSLocalizedString("Network error: %@", comment: ""), error.localizedDescription)
        }
    }
}

protocol HolidayAPIClientProtocol {
    func fetchHolidays(year: Int, countryCode: String) async throws -> [HolidayAPIResponse]
}

final class HolidayAPIClient: HolidayAPIClientProtocol {
    private let baseURL: URL
    private let session: URLSession
    
    init(
        baseURL: URL = URL(string: "https://date.nager.at/api/v3/publicholidays")!,
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.session = session
    }
    
    func fetchHolidays(year: Int, countryCode: String) async throws -> [HolidayAPIResponse] {
        let url = baseURL.appendingPathComponent("\(year)/\(countryCode)")
        
        do {
            let (data, response) = try await session.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200 else {
                throw HolidayAPIError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            return try decoder.decode([HolidayAPIResponse].self, from: data)
        } catch let error as DecodingError {
            throw HolidayAPIError.decodingError(error)
        } catch {
            throw HolidayAPIError.networkError(error)
        }
    }
} 
