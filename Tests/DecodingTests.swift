import XCTest
@testable import sample

class DecodingTests: XCTestCase {
    
    func test_jsonDecoding() {
        guard let json = try? loadContents(of: "jsonResponse", with: "json") else {
            XCTFail("Couldn't fetch load contents of jsonResponse")
            return
        }
        do {
            let decoded = try JSONDecoder().decode(Forecast.self, from: json)

            XCTAssertNotNil(decoded)
            
            guard let firstItem = decoded.items.first else {
                XCTFail("You should have at least one item")
                return
            }
            
            XCTAssertEqual(firstItem.dateTimeUnix, 1635940800)
            XCTAssertEqual(firstItem.main.temperature, 7.53)
            XCTAssertEqual(firstItem.main.feelsLike, 5.29)
            XCTAssertEqual(firstItem.main.minimumTemperature, 7.53)
            XCTAssertEqual(firstItem.main.maximumTemperature, 10.04)
            
            guard let firstWeather = firstItem.weather.first else {
                XCTFail("You should have at least one weather item")
                return
            }
            
            XCTAssertEqual(firstWeather.id, 802)
            XCTAssertEqual(firstWeather.main, "Clouds")
            XCTAssertEqual(firstWeather.weatherDescription, "scattered clouds")
            XCTAssertEqual(firstWeather.icon, "03d")
        } catch {
            XCTFail("Couldn't decode results from jsonResponse \(String(describing: error))")
        }
    }
    
    func test_forecastGetters() {
        guard let json = try? loadContents(of: "jsonResponse", with: "json") else {
            XCTFail("Couldn't fetch load contents of jsonResponse")
            return
        }
        do {
            let decoded = try JSONDecoder().decode(Forecast.self, from: json)

            XCTAssertNotNil(decoded)
            
            
            guard let firstItem = decoded.items.first else {
                XCTFail("You should have at least one item")
                return
            }
            
            XCTAssertEqual(firstItem.dateTime, Date(timeIntervalSince1970: TimeInterval(1635940800)))
        } catch {
            XCTFail("Couldn't decode from jsonResponse \(String(describing: error))")
        }
    }
}
