import UIKit

protocol Identifiable {
    static var identifier: String { get }
}

extension Identifiable {
    static var identifier: String {
        return String(describing: self)
    }
}

typealias CollectionViewCell = UICollectionViewCell & Identifiable

extension UICollectionView {
    func dequeue<T: CollectionViewCell>(at indexPath: IndexPath) -> T {
        guard let cell = dequeueReusableCell(withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Cell with reuse identifier \(T.identifier) is not of type \(T.self)")
        }
        return cell
    }
    
    func register<T: CollectionViewCell>(_ type: T.Type) {
        register(UINib(nibName: type.identifier, bundle: nil), forCellWithReuseIdentifier: type.identifier)
    }
}
