import Foundation
import MapKit

struct Landmark: Identifiable, Hashable {
    let placeMark: MKPlacemark
    let id = UUID()
    
    var name: String {
        placeMark.name ?? ""
    }
    
    var title: String {
        placeMark.title ?? ""
    }
    
    var coordinate: CLLocationCoordinate2D {
        placeMark.coordinate
    }
}
