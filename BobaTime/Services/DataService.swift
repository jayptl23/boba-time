import Foundation
import MapKit

protocol DataServiceProtocol {
    func fetchBusinesses(location: CLLocationCoordinate2D) async throws -> [Business]
}

final class DataService: DataServiceProtocol {
    
    private var urlSession: URLSession
    
    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }
    
    func fetchBusinesses(location: CLLocationCoordinate2D) async throws -> [Business] {
    
        let url = try createURL(latitude: location.latitude, longitude: location.longitude)
        let request = setupURLRequest(url: url)
        
        let (data, response) = try await self.urlSession.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            let statusCode = (response as! HTTPURLResponse).statusCode
            throw DataServiceError.invalidStatusCode(statusCode: statusCode)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let decodedAPIResponse = try decoder.decode(SearchResponse.self, from: data)
        return decodedAPIResponse.businesses
    }
    
    private func createURL(latitude: Double, longitude: Double) throws -> URL {
        let endpoint = "https://api.yelp.com/v3/businesses/search?latitude=\(latitude)&longitude=\(longitude)&sort_by=distance&term=boba"
        guard let url = URL(string: endpoint) else {
            throw DataServiceError.invalidURL
        }
        return url
    }
    
    private func setupURLRequest(url: URL) -> URLRequest {
        // TODO: Hide API Key
        let apiKey = "api goes here"
        
        var request = URLRequest(url: url)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        return request
    }
}

enum DataServiceError: Error {
    case invalidStatusCode(statusCode: Int)
    case invalidURL
}


extension DataServiceError: LocalizedError {
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "URL isn't valid"
        case .invalidStatusCode(let statusCode):
            return "Expected status code 200. Received \(statusCode)."
        }
    }
}
