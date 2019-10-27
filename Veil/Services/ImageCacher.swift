import Foundation
import RxSwift

protocol Cacher {
    func save(_ data: Data, named name: String)
    func retrieve(named name: String) -> Observable<Data?>
}

final class ImageCacher: Cacher {

    private let queue = DispatchQueue(label: "IMAGE_CACHER_SERIAL_QUEUE")
    // we need this queue to synchronize access to `filesInQueue`
    // and using `queue` might take some time if some images are currently being written
    private let filesQueue = DispatchQueue(label: "FILES_IN_QUEUE_SERIAL_QUEUE")

    private let cache = NSCache<NSString, NSData>()
    private lazy var filesInQueue = Set<String>() // Ideally we'd have an Atomic wrapper over this

    private lazy var documentsDirectory = AppEnvironment.storage.documentsDirectory

    func save(_ data: Data, named name: String) {
        cache.setObject(data as NSData, forKey: name as NSString)
        // This function will not be called from inside, and outside calls cannot happen on `filesQueue` thread,
        // so no dead-lock here
        if filesQueue.sync(execute: { // thread-safe check whether the file is currently being written to disk
            let contains = filesInQueue.contains(name)
            if !contains { filesInQueue.insert(name) }

            return contains
        }) { return }
        queue.async {
            // Explicitly capturing self here (in a real project view will deallocate,
            // but we need to keep saving all images)
            let path = self.fullPath(forImageNamed: name)
            AppEnvironment.storage.createFile(atPath: path, contents: data)
            self.filesQueue.async { self.filesInQueue.remove(name) }
        }
    }

    func retrieve(named name: String) -> Observable<Data?> {
        if let data = cache.object(forKey: name as NSString) as Data? {
            return .just(data)
        }
        return Observable.create { observer in
            let path = self.fullPath(forImageNamed: name)
            let complete: (Data?) -> Void = { data in
                observer.onNext(data)
                observer.onCompleted()
            }
            if AppEnvironment.storage.fileExists(atPath: path) {
                self.queue.async {
                    AppEnvironment.storage.contents(atPath: path).map(complete)
                }
            } else {
                // The file might still be in queue, asyncing it on `filesQueue`
                // will retrieve it after it's saved since it's serial
                self.filesQueue.async {
                    guard self.filesInQueue.contains(name) == true else { return complete(nil) }
                    self.queue.async {
                        let contents = AppEnvironment.storage.contents(atPath: path)
                        contents.map { self.cache.setObject($0 as NSData, forKey: name as NSString) }
                        complete(contents)
                    }
                }
            }

            // we'd normally unqueue the block here, but no time to switch to operation queue
            // or write a custom Rx wrapper over file manager
            return Disposables.create()
        }
    }

    private func fullPath(forImageNamed name: String) -> String {
        return documentsDirectory
            .appendingPathComponent("Images")
            .appendingPathComponent(name + ".jpg").path
    }
}
