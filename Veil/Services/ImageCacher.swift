import Foundation

final class ImageCacher: Cacher {

    private let queue = DispatchQueue(label: "IMAGE_CACHER_SERIAL_QUEUE")
    private let filesQueue = DispatchQueue(label: "FILES_IN_QUEUE_SERIAL_QUEUE")

    private let cache = NSCache<NSString, NSData>()
    private lazy var filesInQueue = Set<String>() // Ideally we'd have an Atomic wrapper over this

    private lazy var documentsDirectory = AppEnvironment.storage.documentsDirectory

    func save(_ data: Data, named name: String) {
        cache.setObject(data as NSData, forKey: name as NSString)
        // This function will not be called from inside, and outside calls cannot happen on `filesQueue` thread,
        // so no dead-lock here
        if filesQueue.sync(execute: { filesInQueue.contains(name) }) { return }
        filesQueue.async { self.filesInQueue.insert(name) }
        queue.async {
            // Explicitly capturing self here (in a real project view will deallocate,
            // but we need to keep saving all images)
            let path = self.fullPath(forImageNamed: name)
            AppEnvironment.storage.createFile(atPath: path, contents: data)
            self.filesQueue.async { self.filesInQueue.remove(name) }
        }
    }

    func retrieve(named name: String,
                  completionQueue: DispatchQueue? = nil,
                  completion: @escaping (Data?) -> Void) {
        let callback: (Data?) -> Void = { data in
            completionQueue?.async { completion(data) } ?? completion(data)
        }
        if let data = cache.object(forKey: name as NSString) as Data? {
            return callback(data)
        }
        let path = fullPath(forImageNamed: name)
        if AppEnvironment.storage.fileExists(atPath: path) {
            queue.async {
                callback(AppEnvironment.storage.contents(atPath: path))
            }
        }
        // The file might still be in queue, asyncing it on `filesQueue`
        // will retrieve it after it's saved since it's serial
        filesQueue.async { [weak self] in
            guard self?.filesInQueue.contains(name) == true else { return callback(nil) }
            self?.queue.async {
                let contents = AppEnvironment.storage.contents(atPath: path)
                contents.map { self?.cache.setObject($0 as NSData, forKey: name as NSString) }
                callback(contents)
            }
        }
    }

    private func fullPath(forImageNamed name: String) -> String {
        return documentsDirectory
            .appendingPathComponent("Images")
            .appendingPathComponent(name + ".jpg").path
    }
}
