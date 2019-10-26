import RxSwift

protocol ImageFetcher {
    func search(_ query: String, page: Int) -> Observable<[Image]>
}
