import Foundation
import RxSwift
import Differentiator

protocol ImageFetcher {
    func search(_ query: String, page: Int) -> Observable<[FlickrImage]>
}

struct FlickrPhotos: Decodable {
    let page: Int
    let pages: Int
    let perpage: Int
    let total: String
    let photo: [FlickrImage]
}

struct FlickrResponse: Decodable {
    let photos: FlickrPhotos
}

final class FlickrImageFetcher: ImageFetcher {
    let host = URL(string: "https://api.flickr.com")!

    func search(_ query: String, page: Int) -> Observable<[FlickrImage]> {
        guard let url = buildURL(for: query, page: page) else {
            return .error(ImageSearchError.invalidSearchTerm(query) )
        }
        return AppEnvironment.network.data(request: URLRequest(url: url))
            .map {
                try JSONDecoder().decode(FlickrResponse.self, from: $0).photos.photo
                    .filter { $0.farm != 0 } // there are some erroneous images that come with farm = 0 which doesn't exist at all
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
