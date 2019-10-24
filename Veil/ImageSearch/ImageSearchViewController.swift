import UIKit

protocol ImageSearchViewInput: class {
    func displayError(_ error: String)
    func insert(at indexPaths: [IndexPath])
    func delete(at indexPaths: [IndexPath])
}

final class ImageSearchViewController: UIViewController, StoryboardInstantiable {

    static let storyboardName = "Main"
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchBarContainerView: UIView!
    var searchController: UISearchController!

    private let interitemSpacing: CGFloat = 10
    private let sectionInsets: CGFloat = 10
    private let numberOfItemsInRow = 3

    var output: ImageSearchViewOutput!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = UISearchController(searchResultsController: nil)
        searchBarContainerView.embedSubview(searchController.searchBar)
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        definesPresentationContext = true

        collectionView.register(ImageCollectionViewCell.self)
        collectionView.register(ActivityIndicatorReusableView.self)
    }
}

extension ImageSearchViewController: ImageSearchViewInput {
    func displayError(_ error: String) {
        let alert = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alert, animated: false, completion: nil)
    }

    func insert(at indexPaths: [IndexPath]) {
        collectionView.insertItems(at: indexPaths)
    }

    func delete(at indexPaths: [IndexPath]) {
        collectionView.deleteItems(at: indexPaths)
    }
}

extension ImageSearchViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return output.numberOfImages
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell: ImageCollectionViewCell = collectionView.dequeue(at: indexPath)
        if let image = output.getImage(at: indexPath) {
            cell.displayImage(image)
        }
        
        return cell
    }
}

extension ImageSearchViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView,
                        willDisplaySupplementaryView view: UICollectionReusableView,
                        forElementKind elementKind: String,
                        at indexPath: IndexPath) {
        output.loadNext(query: searchController.searchBar.text ?? "")
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
        footer.startLoading()

        return footer
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let text = searchController.searchBar.text, text.count > 0 else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}

extension ImageSearchViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        searchController.searchBar.text.map(output.search)
    }
}
