@testable import Veil
import Foundation
import RxSwift

final class MockNetwork: Network {

    let requests = PublishSubject<URL>()

    var dataStub = Data()
    var dataRequest: URLRequest?
    var dataCalled = false
    func data(request: URLRequest) -> Observable<Data> {
        dataRequest = request
        dataCalled = true
        requests.onNext(request.url!)

        return .just(dataStub)
    }
}
