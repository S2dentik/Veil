import Foundation
import RxSwift

struct Image: Decodable, Hashable {
    let id: String
    let farm: Int
    let server: String
    let secret: String

    var url: URL {
        return URL(string: "http://farm\(farm).static.flickr.com")!
            .appendingPathComponent(server)
            .appendingPathComponent("\(id)_\(secret).jpg")
    }
}

struct FlickrPhotos: Decodable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [Image]
}

struct FlickrResponse: Decodable {
    let photos: FlickrPhotos
}

final class FlickrImageFetcher: ImageFetcher {
    let host = URL(string: "https://api.flickr.com")!

    func search(_ query: String, page: Int) -> Observable<[Image]> {
        guard let url = buildURL(for: query, page: page) else {
            return .error(ImageSearchError.invalidSearchTerm(query) )
        }
        return URLSession.shared.rx.data(request: URLRequest(url: url))
            .flatMap { data in
                return Observable.create { observer in
                    do {
                        let response = try JSONDecoder().decode(FlickrResponse.self, from: data)
                        observer.onNext(response.photos.photo)
                    } catch {
                        observer.onError(ImageSearchError.decodingError(error))
                    }
                    return Disposables.create()
                }
        }
    }

    private func buildURL(for query: String, page: Int) -> URL? {
        let baseURL = host
            .appendingPathComponent("services")
            .appendingPathComponent("rest")
        guard var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: false) else {
            return nil
        }
        components.queryItems = [
            URLQueryItem(name: "method", value: "flickr.photos.search"),
            URLQueryItem(name: "api_key", value: "3e7cc266ae2b0e0d78e279ce8e361736"),
            URLQueryItem(name: "format", value: "json"),
            URLQueryItem(name: "nojsoncallback", value: "1"),
            URLQueryItem(name: "safe_search", value: "1"),
            URLQueryItem(name: "page", value: "\(page)"),
            URLQueryItem(name: "text", value: query)
        ]

        return components.url
    }
}
