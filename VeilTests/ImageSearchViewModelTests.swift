@testable import Veil
import XCTest
import RxSwift

final class ImageSearchViewModelTests: XCTestCase {

    var subject: ImageSearchViewModel!

    var history: MockSearchHistory!
    var fetcher: MockImageFetcher!
    var cacher: MockImageCacher!

    var network: MockNetwork!

    var disposeBag = DisposeBag()

    override func setUp() {
        super.setUp()

        history = MockSearchHistory()
        fetcher = MockImageFetcher()
        cacher = MockImageCacher()
        let services = ImageSearchServices(history: history, fetcher: fetcher, cacher: cacher)

        network = MockNetwork()
        AppEnvironment.current.network = network

        subject = ImageSearchViewModel(services: services)
    }

    override func tearDown() {
        disposeBag = DisposeBag()

        super.tearDown()
    }

    func test_dataForImage_returnsCachedValueIfAvailable() {
        // GIVEN
        cacher.retrieveStub = "randomData".data(using: .utf8)!

        // WHEN
        let data = try! subject
            .data(for: Image(id: "someId", url: URL(string: "someURL")!))
            .toBlocking()
            .first()

        // THEN
        XCTAssertEqual(data, cacher.retrieveStub)
        XCTAssertFalse(network.dataCalled)
    }

    func test_dataForImage_whenImageNotCached_firesRequest() {
        // GIVEN
        network.dataStub = "randomData".data(using: .utf8)!

        // WHEN
        let data = try! subject
            .data(for: Image(id: "someId", url: URL(string: "someURL")!))
            .toBlocking()
            .first()

        // THEN
        XCTAssertEqual(data, network.dataStub)
    }

    func test_bind_whenQueryPerformed_savesQueryToHistory() {
        // GIVEN
        let view = MockImageSearchView()
        let query = "some_query"
        view.search.accept(query)

        // WHEN
        subject.bind(to: view)
        view.searchFinishedSubject.onNext(())

        // THEN
        XCTAssertEqual(history.searchQuery, query)
    }

    func test_bind_whenViewScrolledToBottom_searchesNextPage() {
        // GIVEN
        let view = MockImageSearchView()
        let query = "some_query"
        view.search.accept(query)

        fetcher.searchStub = [FlickrImage(id: "id", farm: 27, server: "server7", secret: "secret5")]

        // WHEN
        subject.bind(to: view)
        view.scrolledToBottomSubject.onNext(())

        // THEN
        let images = try! subject.images.toBlocking().first()
        XCTAssertEqual(images, fetcher.searchStub.map { Image(id: $0.id, url: $0.url) })
    }

    func test_bind_subsequentSearches_startWithTheInitialPage() {
        // GIVEN
        let view = MockImageSearchView()
        let firstQuery = "some_query"
        let nextQuery = "some_other_query"
        view.search.accept(firstQuery)

        let pageExpectation = XCTestExpectation(description: "Request performed with correct page")

        fetcher.searchStub = [FlickrImage(id: "id", farm: 27, server: "server7", secret: "secret5")]

        fetcher.searchSubject.bind { query, page in
            if page == 1 && query == nextQuery { pageExpectation.fulfill() }
        }.disposed(by: disposeBag)

        // WHEN
        subject.bind(to: view)
        view.search.accept(nextQuery)

        // THEN
        wait(for: [pageExpectation], timeout: 1)
    }
}
