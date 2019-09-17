@testable import Veil
import Foundation

final class MockImageCacher: Cacher {

    var saveCalledName: String?
    var saveCalledData: Data?
    var saveCalled = false
    func save(_ data: Data, named name: String) {
        saveCalled = true
        saveCalledData = data
        saveCalledName = name
    }

    var retrieveCalled = false
    var retrieveCalledName: String?
    func retrieve(named name: String,
                  completionQueue: DispatchQueue?,
                  completion: @escaping (Data?) -> Void) {
        retrieveCalled = true
        retrieveCalledName = name
    }
}
