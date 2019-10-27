import Foundation

struct FlickrImage: Decodable, Hashable {
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
