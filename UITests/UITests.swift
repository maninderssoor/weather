import XCTest

class UITests: XCTestCase {

    let application = XCUIApplication()
    let timeout: TimeInterval = 6.0
    
    func test_dataLoaded() {
        application.launch()
        
        addUIInterruptionMonitor(withDescription: "Location") { alert -> Bool in
            alert.buttons["Allow While Using App"].tap()
            return true
        }
        application.tap()
        
        let searchButton = application.buttons["search"].firstMatch
        XCTAssertTrue(searchButton.waitForExistence(timeout: timeout))
        searchButton.tap()
        
        let collectionView = application.collectionViews["collectionView"].firstMatch
        XCTAssertTrue(collectionView.waitForExistence(timeout: timeout))
        
        let numberOfVisibleCellsPerRow = 2 + 1
        let fourDays = numberOfVisibleCellsPerRow * 4 // then add one for at least a day cell on the 5th day forecast
        XCTAssertGreaterThanOrEqual(collectionView.cells.count, fourDays + 1)
    }
}
