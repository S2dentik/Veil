import Foundation
import RxSwift

protocol Network {
    func data(request: URLRequest) -> Observable<Data>
}

extension Reactive: Network where Base: URLSession { }
