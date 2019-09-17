import Foundation

enum RequestError: Error {
    case failedRequest(statusCode: Int)
    case responseError(Error)
    case nonHTTPResponse
    case noData
}

extension URLSession {
    func dataTask(with url: URL,
                  completion: @escaping (Result<Data, RequestError>) -> Void) -> URLSessionDataTask {
        return dataTask(with: url) { data, response, error in
            if let error = error as NSError? {
                if error.code == NSURLErrorCancelled { return }
                return completion(.failure(.responseError(error)))
            }
            guard let httpResponse = response as? HTTPURLResponse else {
                return completion(.failure(.nonHTTPResponse))
            }
            if httpResponse.statusCode != 200 {
                return completion(.failure(.failedRequest(statusCode: httpResponse.statusCode)))
            }
            guard let data = data else {
                return completion(.failure(.noData))
            }
            completion(.success(data))
        }
    }
}
