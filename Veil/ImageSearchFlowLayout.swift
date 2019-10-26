import UIKit

final class ImageSearchFlowLayout: UICollectionViewFlowLayout {

    private let numberOfItemsInRow = 3
    private let cellHeight = 150
    var displayFooter = false
    var numberOfItems: UInt = 0 {
        didSet {
            attributes = (0..<numberOfItems).map(calculateAttributesForItem)
        }
    }

    private var attributes = [UICollectionViewLayoutAttributes]()

    override var collectionViewContentSize: CGSize {
        get {
            if numberOfItems == 0 { return .zero }
            let rows = (Int(numberOfItems) - 1) / numberOfItemsInRow + 1 // just avoiding Int(ceil(Double(...))
            let height = rows * cellHeight + rows * Int(minimumInteritemSpacing - 1) + Int(sectionInset.top) + Int(sectionInset.bottom)

            return collectionView.map { CGSize(width: $0.bounds.width, height: CGFloat(height)) } ?? .zero
        }
    }

    override var sectionInset: UIEdgeInsets {
        get { UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10) }
        set { super.sectionInset = newValue }
    }

    override var minimumInteritemSpacing: CGFloat {
        get { 10 }
        set { super.minimumInteritemSpacing = newValue }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        if numberOfItems == 0 { return [] }
        return (0..<numberOfItems)
            .compactMap { layoutAttributesForItem(at: IndexPath(row: Int($0), section: 0)) }
            .filter { $0.frame.intersects(rect) }
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard attributes.count > indexPath.item else { return nil }
        return attributes[indexPath.item]
    }

    override func layoutAttributesForSupplementaryView(ofKind elementKind: String,
                                                       at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard displayFooter, let collectionView = collectionView else { return nil }
        let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        attributes?.size = CGSize(width: collectionView.bounds.width, height: 50)

        return attributes
    }

    private func calculateAttributesForItem(at index: UInt) -> UICollectionViewLayoutAttributes {
        let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: Int(index), section: 0))

        let spacing = sectionInset.left + sectionInset.right
            + minimumInteritemSpacing * (CGFloat(numberOfItemsInRow) - 1)
        let width = Int((collectionView!.bounds.width - spacing) / CGFloat(numberOfItemsInRow))
        let size = CGSize(width: width, height: cellHeight)
        let (horizontalPosition, verticalPosition) = (Int(index) % numberOfItemsInRow, Int(index) / numberOfItemsInRow)
        let origin = CGPoint(x: Int(sectionInset.left) + horizontalPosition * width + horizontalPosition * Int(minimumInteritemSpacing),
                             y: verticalPosition * cellHeight + verticalPosition * Int(minimumInteritemSpacing))
        attributes.frame = CGRect(origin: origin, size: size)

        return attributes
    }
}
