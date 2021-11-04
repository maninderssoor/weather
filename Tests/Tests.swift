import XCTest
import Combine
@testable import sample

class Tests: XCTestCase { }

extension XCTestCase {

    func loadContents(of fileNamed: String, with fileType: String) throws -> Data {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: fileNamed, withExtension: fileType) else {
            return Data()
        }
        return try Data(contentsOf: url)
    }

}

extension HTTPURLResponse {
    
    static var successResponse: HTTPURLResponse {
        HTTPURLResponse(url: URL(string: "http://mock")!,
                        statusCode: 200,
                        httpVersion: "HTTP/1.1",
                        headerFields: nil)!
    }
}
