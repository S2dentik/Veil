@testable import Veil
import Foundation
import RxSwift

final class MockImageCacher: Cacher {

    var saveCalledName: String?
    var saveCalledData: Data?
    var saveCalled = false
    func save(_ data: Data, named name: String) {
        saveCalled = true
        saveCalledData = data
        saveCalledName = name
    }

    var retrieveStub: Data?
    func retrieve(named name: String) -> Observable<Data?> {
        return .just(retrieveStub)
    }
}
