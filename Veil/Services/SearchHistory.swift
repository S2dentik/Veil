import RxSwift
import RxCocoa

protocol SearchHistoryType {
    var queries: BehaviorRelay<[String]> { get }
    func search(_ query: String)
}

final class SearchHistory: SearchHistoryType {
    private var history = [String]() {
        didSet {
            queries.accept(items)
        }
    }

    private var items: [String] {
        var result = [String]()
        for item in history.reversed() where !result.contains(item) && result.count < 5 {
            result.append(item)
        }
        return result
    }

    var queries = BehaviorRelay<[String]>(value: [])

    func search(_ query: String) {
        if query.isEmpty { return }
        history.append(query)
    }
}
