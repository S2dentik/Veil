import Foundation

protocol Network {
    func dataTask(with url: URL,
                  completion: @escaping (Result<Data, RequestError>) -> Void) -> NetworkTask
}

extension URLSession: Network { }
