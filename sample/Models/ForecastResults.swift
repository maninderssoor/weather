import Foundation

struct Forecast: Decodable, Hashable {
    let items: [ForecastItem]
    
    enum CodingKeys: String, CodingKey {
        case items = "list"
    }
}

struct ForecastDay: Hashable, Identifiable {
    let dateTime: Date
    
    var id: Date {
        dateTime
    }
    
    var day: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE d MMMM"
        
        return dateFormatter.string(from: dateTime).capitalized
    }
}

struct ForecastItem: Decodable, Hashable, Identifiable {
    let dateTimeUnix: Int
    let main: ForecastMain
    let weather: [ForecastWeather]
    
    var id: String {
        "\(dateTimeUnix)_\(main.temperature)"
    }
    
    var dateTime: Date {
        Date(timeIntervalSince1970: TimeInterval(dateTimeUnix))
    }
    
    
    var dateOrder: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        
        return dateFormatter.string(from: dateTime)
    }
    
    var formattedTime: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        return dateFormatter.string(from: dateTime)
    }
    
    var formattedTemperature: String {
        return "\(main.temperature) °C"
    }
    
    enum CodingKeys: String, CodingKey {
        case dateTimeUnix = "dt"
        case main
        case weather
    }
}

struct ForecastMain: Decodable, Hashable {
    let temperature: Double
    let feelsLike: Double
    let minimumTemperature: Double
    let maximumTemperature: Double
    
    enum CodingKeys: String, CodingKey {
        case temperature = "temp"
        case feelsLike = "feels_like"
        case minimumTemperature = "temp_min"
        case maximumTemperature = "temp_max"
    }
}

struct ForecastWeather: Decodable, Hashable {
    let id: Int
    let main: String
    let weatherDescription: String
    let icon: String
    
    var imageUrlString: String {
        "https://openweathermap.org/img/wn/\(icon)@2x.png"
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case main
        case weatherDescription = "description"
        case icon
    }
}
