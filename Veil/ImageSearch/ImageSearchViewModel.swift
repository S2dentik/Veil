import RxSwift
import RxCocoa
import Differentiator

struct ImageSearchServices {
    let history: SearchHistoryType
    let fetcher: ImageFetcher
    let cacher: Cacher
}

struct Image: Equatable {
    var id: String
    var url: URL
}

extension Image: IdentifiableType {
    var identity: URL { url }
}

protocol ImageSearchViewModelType: class {
    var pastSearches: BehaviorRelay<[String]> { get }
    var images: Observable<[Image]> { get }
    func data(for image: Image) -> Observable<Data>
}

final class ImageSearchViewModel: ImageSearchViewModelType {

    private let disposeBag = DisposeBag()

    private var page = 1
    private let imagesSubject = BehaviorRelay<[Image]>(value: [])

    lazy var images = self.imagesSubject.asObservable()
    lazy var pastSearches = self.services.history.queries

    private let services: ImageSearchServices

    init(services: ImageSearchServices) {
        self.services = services
    }

    func data(for image: Image) -> Observable<Data> {
        let downloadImage = {
            AppEnvironment.network.data(request: URLRequest(url: image.url))
                .do(onNext: { [weak self] data in self?.services.cacher.save(data, named: image.id) })
        }
        return services.cacher.retrieve(named: image.id)
            .flatMap { $0.map { .just($0) } ?? downloadImage() }
    }

    func bind(to view: ImageSearchView) {
        view.searchFinished
            .subscribe(onNext: { [weak self] in self?.services.history.search(view.search.value) })
            .disposed(by: disposeBag)
        let loadNext = view.scrolledToBottom
            .do(onNext: { [weak self] in self?.page += 1 })
            .map { view.search.value }
        let searchText = Observable.merge(loadNext,
                                          view.search
                                            .distinctUntilChanged()
                                            .do(onNext: { [weak self] _ in self?.resetState() })
                                            .debounce(.milliseconds(500),
                                                      scheduler: MainScheduler.instance))
        let searchParams = searchText
            .compactMap { [weak self] query in self.map { (query, $0.page) }}
        let search = searchParams
            .flatMap { [weak self] (query, page) in self.map { $0.search(query, page: page) } ?? .empty() }
        search
            .subscribeOn(MainScheduler.instance)
            .map { [weak self] newImages in
                guard let self = self else { return [] }
                var distinctImages = self.imagesSubject.value
                for image in newImages where !distinctImages.contains(image) {
                    distinctImages.append(image)
                }
                return distinctImages
            }
            .bind(to: imagesSubject)
            .disposed(by: disposeBag)
    }

    private func search(_ query: String, page: Int) -> Observable<[Image]> {
        if query.isEmpty {
            resetState()

            return .empty()
        }
        return services.fetcher.search(query, page: page)
            .map { $0.lazy.map { ($0.id, $0.url) }.map(Image.init) }
    }

    private func resetState() {
        page = 1
        imagesSubject.accept([])
    }
}
