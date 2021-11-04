import Foundation
import Combine

protocol APIProvider {
    typealias APIResponse = URLSession.DataTaskPublisher.Output
    func apiResponse(for url: URL) -> AnyPublisher<APIResponse, URLError>
}

extension URLSession: APIProvider {
    func apiResponse(for url: URL) -> AnyPublisher<APIResponse, URLError> {
        dataTaskPublisher(for: url).eraseToAnyPublisher()
    }
}
