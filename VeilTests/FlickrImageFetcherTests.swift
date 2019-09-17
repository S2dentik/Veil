@testable import Veil
import XCTest

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

    func test_search_createsTaskAndResumesIt() {
        // GIVEN
        let task = MockNetworkTask()
        network.dataTaskStub = task

        // WHEN
        subject.search("query", page: 1, completion: { _ in })

        // THEN
        XCTAssert(network.dataTaskCalled)
        XCTAssert(task.resumeCalled)
    }

    func test_search_createsURLWithCorrectParameters() {
        // GIVEN
        let task = MockNetworkTask()
        network.dataTaskStub = task

        let query = "query"
        let page = 27

        // WHEN
        subject.search(query, page: page, completion: { _ in })

        // THEN
        let parameters = URLComponents(url: network.dataTaskCalledURL,
                                          resolvingAgainstBaseURL: false)!.queryItems ?? []
        XCTAssert(parameters.contains(URLQueryItem(name: "page", value: "\(page)")))
        XCTAssert(parameters.contains(URLQueryItem(name: "text", value: query)))
    }

    func test_search_cancelsPreviousRequest() {
        // GIVEN
        let task1 = MockNetworkTask()
        let task2 = MockNetworkTask()
        network.dataTaskStub = task1

        // WHEN
        subject.search("query1", page: 1, completion: { _ in })
        network.dataTaskStub = task2
        subject.search("query2", page: 2, completion: { _ in })

        // THEN
        XCTAssert(task1.cancelCalled)
    }
}
