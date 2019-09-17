@testable import Veil

final class MockImageFetcher: ImageFetcher {

    var searchCalled = false
    var searchQuery: String?
    var searchPage: Int?
    var searchStub: Result<[Image], ImageSearchError>?
    func search(_ query: String,
                page: Int,
                completion: @escaping (Result<[Image], ImageSearchError>) -> Void) {
        searchCalled = true
        searchQuery = query
        searchPage = page
        searchStub.map(completion)
    }

    var cancelCalled = false
    func cancel() {
        cancelCalled = true
    }
}
