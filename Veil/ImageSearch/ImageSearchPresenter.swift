import UIKit

protocol ImageSearchViewOutput {
    var numberOfImages: Int { get }
    func getImage(at indexPath: IndexPath) -> Image?
    func search(query: String)
    func loadNext(query: String)
}

final class ImageSearchPresenter: ImageSearchViewOutput {

    var images = [Image]() {
        didSet {
            if oldValue.count == images.count { return }
            let minValue = min(oldValue.count, images.count)
            let indexPaths = (minValue..<(minValue + abs(images.count - oldValue.count)))
                .map { IndexPath(item: $0, section: 0) }
            let update = oldValue.count < images.count ? view?.insert : view?.delete
            update?(indexPaths)
        }
    }
    private var page = 1
    weak var view: ImageSearchViewInput?
    let imageFetcher: ImageFetcher

    init(view: ImageSearchViewInput,
         imageFetcher: ImageFetcher = FlickrImageFetcher()) {
        self.view = view
        self.imageFetcher = imageFetcher
    }

    var numberOfImages: Int {
        return images.count
    }

    func getImage(at indexPath: IndexPath) -> Image? {
        guard indexPath.item < numberOfImages else {
            return nil
        }
        return images[indexPath.item]
    }

    func search(query: String) {
        imageFetcher.cancel()
        images = []
        page = 1
        if query.isEmpty { return }
        search(query: query, page: page)
    }

    func loadNext(query: String) {
        imageFetcher.cancel()
        if query.isEmpty { return }
        page += 1
        search(query: query, page: page)
    }

    private func search(query: String, page: Int) {
        imageFetcher.search(query, page: page) { [weak self] result in
            guard let welf = self else { return }
            UI {
                switch result {
                case .success(let images): welf.images += images
                case .failure(let error): welf.view?.displayError(error.localizedDescription)
                }
            }
        }
    }
}
