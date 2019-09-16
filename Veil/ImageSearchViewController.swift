import UIKit

class ImageSearchViewController: UIViewController {
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var collectionView: UICollectionView!
    
    private let interitemSpacing: CGFloat = 10
    private let sectionInsets: CGFloat = 10
    private let numberOfItemsInRow = 3

    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.register(ImageCollectionViewCell.self)
        collectionView.register(ActivityIndicatorReusableView.self)
    }
}

extension ImageSearchViewController: UICollectionViewDelegate {
    
}

extension ImageSearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeue(at: indexPath)
        cell.contentView.backgroundColor = .red
        
        return cell
    }
}

extension ImageSearchViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        let spacing = sectionInsets * 2 + interitemSpacing * (CGFloat(numberOfItemsInRow) - 1)
        let width = (collectionView.bounds.width - spacing) / CGFloat(numberOfItemsInRow)
        
        return CGSize(width: Int(width), height: 150)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return interitemSpacing
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: sectionInsets, left: sectionInsets, bottom: sectionInsets, right: sectionInsets)
    }

    func collectionView(_ collectionView: UICollectionView,
                        viewForSupplementaryElementOfKind kind: String,
                        at indexPath: IndexPath) -> UICollectionReusableView {
        let footer: ActivityIndicatorReusableView = collectionView.dequeue(at: indexPath)

        return footer
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}
