import RxSwift

final class SearchHistory {
    private var history = ["1", "2", "3"]

    var items: [String] {
        var result = [String]()
        for item in history.reversed() where result.count < 5 {
            if result.contains(item) { continue }
            result.append(item)
        }
        return result
    }

    func search(_ query: String) {
        history.append(query)
    }
}
