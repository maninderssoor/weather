import XCTest
import CoreLocation
@testable import sample

class ForecastAPIServiceTests: XCTestCase {

    func test_createService_isCorrect() {
        let location = CLLocation(latitude: CLLocationDegrees(40.759211),
                                  longitude: CLLocationDegrees(-73.984638))
        let service = ForecastAPIService(location: location)
        
        guard let url = service.url else {
            XCTFail("A URL should have been generated for this service")
            return
        }
        
        guard let queryItems = URLComponents(string: url.absoluteString)?.queryItems else {
            XCTFail("This service should have query items")
            return
        }
        
        XCTAssertEqual(queryItems.count, 4)
        XCTAssertEqual(queryItems.filter { $0.name == "lat" }.first?.value , "\(location.coordinate.latitude)")
        XCTAssertEqual(queryItems.filter { $0.name == "lon" }.first?.value , "\(location.coordinate.longitude)")
        XCTAssertEqual(queryItems.filter { $0.name == "units" }.first?.value , "Metric")
        XCTAssertEqual(queryItems.filter { $0.name == "appId" }.first?.value , Environment.appId)
    }

}
