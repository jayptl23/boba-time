import Foundation
import MapKit

struct MapLocation: Identifiable {
    let id = UUID()
    let name: String
    let latitude: Double
    let longitude: Double
    var coordinate: CLLocationCoordinate2D {
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

final class BusinessViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    @Published private(set) var businesses: [Business] = []
    @Published private(set) var isLoading = false
    @Published var hasError = false
    @Published private(set) var error: DataServiceError?
    @Published private(set) var annotations: [MapLocation] = []
    @Published var region = MKCoordinateRegion.defaultRegion()
    
    //MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.498092, longitude: -79.612909), span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1))
    
    private var dataService: DataServiceProtocol
    
    init(dataService: DataServiceProtocol) {
        self.dataService = dataService
    }
    
    func fetchBusinesses(region: MKCoordinateRegion) async {
        do {
            let returnedBusinesses = try await self.dataService.fetchBusinesses(location: region.center)
            await MainActor.run {
                defer { isLoading = false }
                isLoading = true
                businesses = returnedBusinesses
                annotations = businesses.map {
                    MapLocation(name: $0.name, latitude: $0.coordinates.latitude, longitude: $0.coordinates.longitude)
                }
            }
        } catch {
            print(error)
            hasError = true
            self.error = error as? DataServiceError
        }
    }
}
