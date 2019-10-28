@testable import Veil
import RxSwift

final class MockImageFetcher: ImageFetcher {

    let searchSubject = PublishSubject<(String, Int)>()

    var searchQuery: String?
    var searchPage: Int?
    var searchStub = [FlickrImage]()
    func search(_ query: String, page: Int) -> Observable<[FlickrImage]> {
        searchQuery = query
        searchPage = page
        searchSubject.onNext((query, page))

        return .just(searchStub)
    }
}
