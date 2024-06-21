import XCTest
@testable import BobaTime
import MapKit

final class DataService_Tests: XCTestCase {
    
    private var dataService: DataService!
    private var expectation: XCTestExpectation!
    
    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        
        dataService = DataService(urlSession: urlSession)
        expectation = expectation(description: "Expectation")
    }
    
    func test_fetchBusinesses_zeroBusinesses_successfulResponse() async {
        let jsonString = """
                         {
                            "businesses": []
                         }
                         """
        let data = jsonString.data(using: .utf8)
        
        MockURLProtocol.loadingHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        
        do {
            let returnedBusinesses = try await dataService.fetchBusinesses(location: CLLocationCoordinate2D(latitude: 1, longitude: 1))
            XCTAssertTrue(returnedBusinesses.isEmpty)
            self.expectation.fulfill()
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchBusinesses_successfulResponse() async {
        let jsonString = """
                         {
                           "businesses": [
                             {
                               "id": "1",
                               "name": "Shop 1",
                               "image_url": "http",
                               "rating": 4.5,
                               "location": {
                                 "display_address": [
                                   "street",
                                   "city",
                                   "postal code",
                                   "country"
                                 ]
                               },
                               "coordinates": {
                                 "latitude": 21.9846,
                                 "longitude": 33.7769
                               }
                             }
                           ]
                         }
                         """
        let data = jsonString.data(using: .utf8)
        
        MockURLProtocol.loadingHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        
        do {
            let returnedBusinesses = try await dataService.fetchBusinesses(location: CLLocationCoordinate2D(latitude: 1, longitude: 1))
            XCTAssertEqual(returnedBusinesses.count, 1)
            self.expectation.fulfill()
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchBusinesses_Throws_invalidStatusCode() async {
        
        MockURLProtocol.loadingHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 500, httpVersion: nil, headerFields: nil)!
            return (response, nil)
        }
        
        do {
            let _ = try await dataService.fetchBusinesses(location: CLLocationCoordinate2D(latitude: 1, longitude: 1))
            XCTFail("Unexpected successful response")
        } catch {
            if let error = error as? DataServiceError {
                switch error {
                case .invalidStatusCode(statusCode: _):
                    XCTAssertEqual(error.localizedDescription, "Expected status code 200. Received 500.")
                    self.expectation.fulfill()
                    break
                case .invalidURL:
                    XCTFail("Unexpected invalid url")
                    self.expectation.fulfill()
                    break
                }
            } else {
                XCTFail("Unexpected error: \(error)")
                self.expectation.fulfill()
            }
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_fetchBusinesses_Throws_FailedToDecode() async {
        // MISSING NAME
         let jsonString = """
                          {
                            "businesses": [
                              {
                                "id": "PFKvRkuqgl8pkbM5vVanEg",
                                "alias": "real-fruit-bubble-tea-toronto-25",
                                "image_url": "https:s3-media2.fl.yelpcdn.com/bphoto/BkaE9FwZXdmwwPWo2gUOXw/o.jpg",
                                "is_closed": false,
                                "url": "https:www.yelp.com/biz/real-fruit-bubble-tea-toronto-25?adjust_creative=h9OtUCqN3sjmC7KIJSLcug&utm_campaign=yelp_api_v3&utm_medium=api_v3_business_search&utm_source=h9OtUCqN3sjmC7KIJSLcug",
                                "review_count": 1,
                                "categories": [
                                  {
                                    "alias": "bubbletea",
                                    "title": "Bubble Tea"
                                  }
                                ],
                                "rating": 4,
                                "coordinates": {
                                  "latitude": 43.6711985568392,
                                  "longitude": -79.3943792918473
                                },
                                "transactions": [],
                                "location": {
                                  "address1": "55 Avenue Road",
                                  "address2": "",
                                  "address3": null,
                                  "city": "Toronto",
                                  "zip_code": "M5R 3L2",
                                  "country": "CA",
                                  "state": "ON",
                                  "display_address": [
                                    "55 Avenue Road",
                                    "Toronto, ON M5R 3L2",
                                    "Canada"
                                  ]
                                },
                                "phone": "",
                                "display_phone": "",
                                "distance": 395.07944212481624
                              }
                            ]
                          }
                          """
        
        let data = jsonString.data(using: .utf8)

        MockURLProtocol.loadingHandler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, data)
        }
        
        do {
            let _ = try await dataService.fetchBusinesses(location: CLLocationCoordinate2D(latitude: 1, longitude: 1))
            XCTFail("Unexpected successful response")
            self.expectation.fulfill()
        } catch DecodingError.keyNotFound(_, _) {
            self.expectation.fulfill()
        } catch {
            XCTFail("Unexpected error: \(error)")
            self.expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 1.0)
    }
}
