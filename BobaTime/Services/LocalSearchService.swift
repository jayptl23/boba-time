import Foundation
import MapKit
import Combine

class LocalSearchService: ObservableObject {
    let locationManager = LocationManager()
    var cancellables = Set<AnyCancellable>()
    
    @Published var region = MKCoordinateRegion.defaultRegion()
    @Published var landmarks: [Landmark] = []
    @Published var landmark: Landmark?
    
    init() {
        locationManager.$region.assign(to: \.region, on: self)
            .store(in: &cancellables)
    }
    
    func search(query: String) {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
        request.region = locationManager.region // narrows the search space to the given region
        
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            if let response = response {
                let mapItems = response.mapItems
                self.landmarks = mapItems.map {
                    Landmark(placeMark: $0.placemark)
                }
            }
        }
    }
}
