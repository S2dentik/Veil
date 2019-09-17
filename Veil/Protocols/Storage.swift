import Foundation

protocol Storage {
    var documentsDirectory: URL { get }
    func fileExists(atPath path: String) -> Bool
    func contents(atPath path: String) -> Data?
    func createFile(atPath path: String, contents data: Data?)
}

extension FileManager: Storage {
    var documentsDirectory: URL {
        return urls(for: .documentDirectory, in: .userDomainMask).first!
    }

    func createFile(atPath path: String, contents data: Data?) {
        createFile(atPath: path, contents: data, attributes: nil)
    }
}
