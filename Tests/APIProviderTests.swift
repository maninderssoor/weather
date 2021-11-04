import XCTest
import Combine

@testable import sample

class APIProviderTests: XCTestCase {

    func test_apiProvider() {
        guard let json = try? loadContents(of: "jsonResponse", with: "json"),
              let url = URL(string: "http://mock") else {
            XCTFail("Couldn't fetch load contents of jsonResponse")
            return
        }
        let mockProvider = MockAPIProvider(data: json,
                                           response: HTTPURLResponse.successResponse)
        
        mockProvider.apiResponse(for: url).sink { _ in } receiveValue: { output in
            XCTAssertNotNil(output.data)
        }.cancel()

    }

}

struct MockAPIProvider: APIProvider {
    
    let data: Data
    let response: HTTPURLResponse
    
    init(data: Data, response: HTTPURLResponse) {
        self.data = data
        self.response = response
    }
    
    func apiResponse(for url: URL) -> AnyPublisher<APIResponse, URLError> {
        return Just((data: data, response: response))
            .setFailureType(to: URLError.self)
            .eraseToAnyPublisher()
    }
}
