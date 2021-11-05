import XCTest
import CoreLocation
@testable import sample

class ForecastViewModelTests: XCTestCase {

    func test_viewModelFetchingData_withSuccess() {
        let expectation = expectation(description: "fetchingDataExpectation")
        guard let json = try? loadContents(of: "jsonResponse", with: "json") else {
            XCTFail("Couldn't fetch load contents of jsonResponse")
            return
        }
        let forecastView = MockForecastView()
        forecastView.didFetchCalled = {
            expectation.fulfill()
        }
        let location = CLLocation(latitude: CLLocationDegrees(40.759211),
                                  longitude: CLLocationDegrees(-73.984638))
        let mockAPI = MockAPIProvider(data: json,
                                      response: HTTPURLResponse.successResponse)
        let viewModel = ForecastViewModel(provider: mockAPI)
        viewModel.view = forecastView
        
        viewModel.fetchData(with: location)
        
        waitForExpectations(timeout: 6.0) { error in
            if let error = error {
                XCTFail("Error fetching data on view model \(String(describing: error))")
            }
        }
        
    }
    
    func test_viewModelFetchingData_withError() {
        let expectation = expectation(description: "fetchingErroneousDataExpectation")
        guard let json = try? loadContents(of: "jsonBadResponse", with: "json") else {
            XCTFail("Couldn't fetch load contents of jsonBadResponse")
            return
        }
        let venueListView = MockForecastView()
        venueListView.didFailCalled = {
            expectation.fulfill()
        }
        let location = CLLocation(latitude: CLLocationDegrees(40.759211),
                                  longitude: CLLocationDegrees(-73.984638))
        let mockAPI = MockAPIProvider(data: json,
                                      response: HTTPURLResponse.successResponse)
        let viewModel = ForecastViewModel(provider: mockAPI)
        viewModel.view = venueListView
        
        viewModel.fetchData(with: location)
        
        waitForExpectations(timeout: 6.0) { error in
            if let error = error {
                XCTFail("Error fetching data on view model \(String(describing: error))")
            }
        }
        
    }

}

private class MockForecastView: ForecastView {
    
    var didFetchCalled: (() -> Void)?
    var didFailCalled: (() -> Void)?
    
    func didFetchData(with snapshot: NSDiffableDataSourceSnapshot<ForecastSection, AnyHashable>) {
        didFetchCalled?()
    }
    
    func didFailFetch(with error: ForecastError) {
        didFailCalled?()
    }
    
    
}
