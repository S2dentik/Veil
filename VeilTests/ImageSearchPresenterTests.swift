@testable import Veil
import XCTest

final class ImageSearchPresenterTestCase: XCTestCase {

    var subject: ImageSearchPresenter!

    var imageFetcher: MockImageFetcher!
    var view: MockImageSearchViewInput!
    var network: MockNetwork!

    override func setUp() {
        super.setUp()

        imageFetcher = MockImageFetcher()
        view = MockImageSearchViewInput()
        network = MockNetwork()

        AppEnvironment.current.network = network

        subject = ImageSearchPresenter(view: view, imageFetcher: imageFetcher)
    }

    func test_search_whenSuccessful_displaysImagesOnTheView() {
        // GIVEN
        let image = MockImage(id: "someID", url: URL(string: "someURL")!)
        imageFetcher.searchStub = .success([image])

        // WHEN
        subject.search(query: "someQuery")

        // THEN
        XCTAssert(view.insertAtIndexPathsCalled)
        XCTAssertEqual(view.insertAtIndexPathsCalledIndexPaths, [IndexPath(item: 0, section: 0)])
    }

    func test_loadNext_searchesImagesForNextPage() {
        for page in 2..<6 {
            // WHEN
            subject.loadNext(query: "someQuery")

            // THEN
            XCTAssertEqual(imageFetcher.searchPage, page)
        }
    }

    func test_search_whenNewQuery_imagesAreDeleted() {
        // GIVEN
        let image = MockImage(id: "someID", url: URL(string: "someURL")!)
        let count = 100
        imageFetcher.searchStub = .success([MockImage](repeating: image, count: count))
        subject.search(query: "someQuery")

        // WHEN
        imageFetcher.searchStub = .success([])
        subject.search(query: "someOtherQuery")

        // THEN
        XCTAssert(view.deleteAtIndexPathsCalled)
        XCTAssertEqual(view.deleteAtIndexPathsCalledIndexPaths, (0..<count).map { IndexPath(item: $0, section: 0) })
    }

    func test_search_cancelsPreviousSearch() {
        // WHEN
        subject.search(query: "someQuery")

        // THEN
        XCTAssert(imageFetcher.cancelCalled)
    }

    func test_loadNext_cancelsPreviousSearch() {
        // WHEN
        subject.loadNext(query: "someQuery")

        // THEN
        XCTAssert(imageFetcher.cancelCalled)
    }

    /// This is more of an integration test
    func test_search_whenEmptyQuery_requestNotStarted() {
        // WHEN
        subject.search(query: "")

        // THEN
        XCTAssertFalse(network.dataTaskCalled)
    }
}
