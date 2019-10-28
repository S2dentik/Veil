@testable import Veil
import RxCocoa

final class MockSearchHistory: SearchHistoryType {
    var queries = BehaviorRelay<[String]>(value: [])

    var searchQuery: String?
    func search(_ query: String) {
        searchQuery = query
    }
}
