import Foundation
import CoreLocation

struct ForecastAPIService {
    let location: CLLocation
    let url: URL?
    
    init(location: CLLocation) {
        let baseUrl = Environment.baseUrl.appendingPathComponent("forecast")
        var urlComponents = URLComponents(string: baseUrl.absoluteString)
        urlComponents?.queryItems = [
            URLQueryItem(name: "lat", value: "\(location.coordinate.latitude)"),
            URLQueryItem(name: "lon", value: "\(location.coordinate.longitude)"),
            URLQueryItem(name: "units", value: "Metric"),
            URLQueryItem(name: "appId", value: Environment.appId)
        ]
        
        self.location = location
        self.url = urlComponents?.url
    }
}
