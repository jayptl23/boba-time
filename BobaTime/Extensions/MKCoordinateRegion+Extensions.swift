import Foundation
import MapKit

extension MKCoordinateRegion {
    
    static func defaultRegion() -> MKCoordinateRegion {
        //return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 37.33233141, longitude: -122.03121860), span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
        return MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 43.498092, longitude: -79.612909), span: MKCoordinateSpan(latitudeDelta: 0.25, longitudeDelta: 0.25))
    }
    
    static func regionFromLandmark(_ landmark: Landmark) -> MKCoordinateRegion {
        return MKCoordinateRegion(center: landmark.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.015, longitudeDelta: 0.015))
    }
}
