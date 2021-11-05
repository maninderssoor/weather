import Foundation
import CoreLocation
import Combine
import UIKit

enum ForecastSection: Int {
    case dayOne = 0
    case dayTwo = 1
    case dayThree = 2
    case dayFour = 3
    case dayFive = 4
}

enum ForecastError: Error {
    case exisiting(description: String)
    case parsing(description: String)
    case network(description: String)
}

class ForecastViewModel {
    
    private var cancellable: AnyCancellable?
    private var isFetching: Bool = false
    
    private let apiProvider: APIProvider
    
    weak var view: ForecastView?
    
    var lastFetchedLocation: CLLocation?
    
    init(provider: APIProvider = URLSession.shared) {
        self.apiProvider = provider
    }
    
    func fetchData(with location: CLLocation) {
        guard !isFetching else { return }
        isFetching = true
        
        guard let url = ForecastAPIService(location: location).url else {
            print("Error fetching a url with the forecast API service")
            return
        }
        
        self.cancellable = apiProvider.apiResponse(for: url)
            .mapError { error in
                ForecastError.network(description: error.localizedDescription)
            }
            .map { $0.data }
            .decode(type: Forecast.self, decoder: JSONDecoder())
            .map { $0.items }
            .mapError { error in
                ForecastError.parsing(description: error.localizedDescription)
            }
            .eraseToAnyPublisher()
            .sink(receiveCompletion: { [weak self] result in
                switch result {
                case .failure(let error):
                    self?.isFetching = false
                    self?.view?.didFailFetch(with: error)
                case .finished:
                    self?.isFetching = false
                    break
                }
            }, receiveValue: { items in
                
                let days = Dictionary(grouping: items) { item in
                    item.dateOrder
                }
                let keys = days.sorted(by: { $0.key < $1.key }).map(\.key)
                
                var snapshot = NSDiffableDataSourceSnapshot<ForecastSection, AnyHashable>()
                
                for index in 0..<keys.count {
                    let key = keys[index]
                    guard let forecastSection = ForecastSection(rawValue: index),
                          let sortedArray = days[key]?.sorted(by: { $0.dateTime < $1.dateTime }),
                          let firstItem = sortedArray.first else { continue }
                    
                    let forecastDay = ForecastDay(dateTime: firstItem.dateTime)
                    
                    var itemsArray: [AnyHashable] = []
                    itemsArray.append(forecastDay)
                    itemsArray.append(contentsOf: sortedArray)
                    
                    snapshot.appendSections([forecastSection])
                    snapshot.appendItems(itemsArray, toSection: forecastSection)
                }
                
                DispatchQueue.main.async {[weak self] in
                    self?.isFetching = false
                    self?.lastFetchedLocation = location
                    self?.view?.didFetchData(with: snapshot)
                }
            })
        
    }
    
}
