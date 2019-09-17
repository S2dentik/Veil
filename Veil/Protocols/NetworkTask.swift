import Foundation

protocol NetworkTask {
    func resume()
    func cancel()
}

extension URLSessionTask: NetworkTask { }
