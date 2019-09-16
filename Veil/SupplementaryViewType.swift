import UIKit

enum SupplementaryViewKind {
    case footer
}

protocol SupplementaryViewType: Identifiable {
    static var kind: SupplementaryViewKind { get }
}

private extension SupplementaryViewType {
    static var uiKitType: String {
        switch kind {
        case .footer: return UICollectionView.elementKindSectionFooter
        }
    }
}

typealias CollectionViewSupplementaryView = UICollectionReusableView & SupplementaryViewType

extension UICollectionView {
    func register<T: CollectionViewSupplementaryView>(_ type: T.Type) {
        register(UINib(nibName: type.identifier, bundle: nil), forSupplementaryViewOfKind: type.uiKitType, withReuseIdentifier: type.identifier)
//        register(type, forSupplementaryViewOfKind: type.uiKitType, withReuseIdentifier: type.identifier)
    }

    func dequeue<T: CollectionViewSupplementaryView>(at indexPath: IndexPath) -> T {
        guard let view = dequeueReusableSupplementaryView(ofKind: T.uiKitType,
                                                          withReuseIdentifier: T.identifier, for: indexPath) as? T else {
            fatalError("Supplementary view with reuse identifier \(T.identifier) is not of type \(T.self)")
        }
        return view
    }
}
