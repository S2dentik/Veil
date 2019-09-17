import Foundation

protocol Cacher {
    func save(_ data: Data, named name: String)
    func retrieve(named name: String, completionQueue: DispatchQueue?, completion: @escaping (Data?) -> Void)
}
