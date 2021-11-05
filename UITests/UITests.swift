import XCTest

class UITests: XCTestCase {

    let application = XCUIApplication()
    let timeout: TimeInterval = 6.0
    
    func test_dataLoaded() {
        application.launch()
        
        let searchButton = application.searchFields.firstMatch
        XCTAssertTrue(searchButton.waitForExistence(timeout: timeout))
        searchButton.typeText("London")
        searchButton.typeText("\n")
        
        let collectionView = application.collectionViews["collectionView"].firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: timeout))
        
        let numberOfVisibleCellsPerRow = 2 + 1
        let fourDays = numberOfVisibleCellsPerRow * 4 // then add one for at least a day cell on the 5th day forecast
        XCTAssertGreaterThanOrEqual(collectionView.cells.count, fourDays + 1)
        
        let mapsButton = application.buttons["mapButton"].firstMatch
        XCTAssertTrue(mapsButton.waitForExistence(timeout: timeout))
        mapsButton.tap()
        
        let mapView = application.otherElements["mapViewController"].firstMatch
        XCTAssertTrue(mapView.waitForExistence(timeout: timeout))
    }
}
