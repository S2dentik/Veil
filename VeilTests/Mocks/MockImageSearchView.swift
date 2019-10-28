@testable import Veil
import RxSwift
import RxCocoa

final class MockImageSearchView: ImageSearchView {
    lazy var scrolledToBottom = scrolledToBottomSubject.asObservable()
    var search = BehaviorRelay<String>(value: "")
    lazy var searchFinished = searchFinishedSubject.asObservable()

    let scrolledToBottomSubject = PublishSubject<Void>()
    let searchFinishedSubject = PublishSubject<Void>()
}
