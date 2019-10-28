@testable import Veil
import XCTest
import RxBlocking

final class FlickrImageFetchrTestCase: XCTestCase {

    var subject: FlickrImageFetcher!
    var storage: MockStorage!
    var network: MockNetwork!

    override func setUp() {
        super.setUp()

        storage = MockStorage()
        network = MockNetwork()

        AppEnvironment.current.storage = storage
        AppEnvironment.current.network = network

        subject = FlickrImageFetcher()
    }

    func test_search_createsURLWithCorrectParameters() {
        // GIVEN
        let query = "query"
        let page = 27

        // WHEN
        _ = subject.search(query, page: page)

        // THEN
        let parameters = network.dataRequest?.url
            .flatMap { URLComponents(url: $0, resolvingAgainstBaseURL: false) }?.queryItems ?? []
        XCTAssert(parameters.contains(URLQueryItem(name: "page", value: "\(page)")))
        XCTAssert(parameters.contains(URLQueryItem(name: "text", value: query)))
    }

    func test_search_firesRequestAndDecodesImage() {
        // GIVEN
        let data = """
        {
        "photos": {
            "page": 1,
            "pages": 200,
            "perpage": 100,
            "total": "47564",
            "photo": [
                {
                    "id": "1",
                    "farm": 4,
                    "server": "5",
                    "secret": "secret",
                    "photos": []
                }
            ]
            }
        }
        """.data(using: .utf8)!
        network.dataStub = data

        // WHEN
        let result = try! subject
            .search("query", page: 1)
            .toBlocking()
            .first()

        // THEN
        XCTAssertEqual(result?.first, try! JSONDecoder().decode(FlickrResponse.self, from: data).photos.photo.first)
    }
}
