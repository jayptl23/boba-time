import Foundation
import MapKit
@testable import BobaTime

final class MockDataService: DataServiceProtocol {
    
    private var data: [Business]
    
    init(data: [Business]? = nil) {
        self.data = data ?? []
    }
    
    func fetchBusinesses(location: CLLocationCoordinate2D) async throws -> [Business] {
        return data
    }
}
