import Foundation

struct SearchResponse: Decodable {
    let businesses: [Business]
}

struct Business: Decodable {

    struct Location: Decodable {
        let displayAddress: [String]
    }

    struct Coordinates: Decodable {
        let latitude: Double
        let longitude: Double
    }

    let id: String
    let name: String
    let imageUrl: String
    let rating: Float
    let location: Location
    let coordinates: Coordinates
}
