@testable import Veil
import Foundation

final class MockNetwork: Network {

    var dataTaskCalledURL = URL(string: "dataTask")!
    var dataTaskCalled = false
    var dataTaskStub = MockNetworkTask()
    func dataTask(with url: URL,
                  completion: @escaping (Result<Data, RequestError>) -> Void) -> NetworkTask {
        dataTaskCalled = true
        dataTaskCalledURL = url

        return dataTaskStub
    }
}

final class MockNetworkTask: NetworkTask {
    var resumeCalled = false
    func resume() {
        resumeCalled = true
    }

    var cancelCalled = false
    func cancel() {
        cancelCalled = true
    }
}
