import XCTest
@testable import BobaTime
import MapKit

final class BusinessViewModel_Tests: XCTestCase {
    
    private var vm: BusinessViewModel!
    
    func test_BusinessViewModel_fetchBusinesses_emptyArray() async {
        let expectation = expectation(description: "Returns empty array")
        
        vm = BusinessViewModel(dataService: MockDataService())
        
        await vm.fetchBusinesses(region: MKCoordinateRegion.defaultRegion())
        
        XCTAssert(vm.businesses.isEmpty)
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 1.0)
    }
    
    func test_BusinessViewModel_fetchBusinesses_nonEmptyArray() async {
        let expectation = expectation(description: "Returns array of 1 business")
        
        let mockData = [Business(id: "1",
                                name: "Shop 1",
                                imageUrl: "",
                                rating: 1,
                                location: Business.Location(displayAddress: ["street", "addr", "city"]),
                                coordinates: Business.Coordinates(latitude: 1, longitude: 1))]
        
        vm = BusinessViewModel(dataService: MockDataService(data: mockData))
        
        await vm.fetchBusinesses(region: MKCoordinateRegion.defaultRegion())
        
        XCTAssertEqual(vm.businesses.count, 1)
        XCTAssertEqual(vm.annotations[0].name, mockData.first!.name)
        expectation.fulfill()
        
        wait(for: [expectation], timeout: 1.0)
    }
}
