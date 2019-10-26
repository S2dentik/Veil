import UIKit

protocol ImageSearchViewInput: class {
    func displayError(_ error: String)
//    func insert(at indexPaths: [IndexPath])
//    func delete(at indexPaths: [IndexPath])
}

final class ImageSearchViewController: UIViewController, StoryboardInstantiable {

    static let storyboardName = "Main"

    let disposeBag = DisposeBag()
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchHistoryTableView: UITableView!
    var searchController: UISearchController!

    fileprivate let interitemSpacing: CGFloat = 10
    fileprivate let sectionInsets: CGFloat = 10
    fileprivate let numberOfItemsInRow = 2

    var output: ImageSearchViewOutput!

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        searchHistoryTableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")

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
                        layout collectionViewLayout: UICollectionViewLayout,
                        referenceSizeForFooterInSection section: Int) -> CGSize {
        guard let text = searchController.searchBar.text, text.count > 0 else { return .zero }
        return CGSize(width: collectionView.bounds.width, height: 50)
    }
}

import RxCocoa
import RxSwift
import RxDataSources

extension ImageSearchViewController {
    static func build(history: SearchHistory, fetcher: ImageFetcher = FlickrImageFetcher()) -> ImageSearchViewController {
        let vc = ImageSearchViewController.instantiate()
        vc.output = ImageSearchPresenter(view: vc)
        _ = vc.view

        Observable.just(history.items)
            .bind(to: vc.searchHistoryTableView.rx.items(cellIdentifier: "UITableViewCell",
                                                         cellType: UITableViewCell.self)) { _, item, cell in
                                                            cell.textLabel?.text = item
        }.disposed(by: vc.disposeBag)

        vc.searchController.searchBar.rx
            .textDidBeginEditing.bind(onNext: { vc.searchHistoryTableView.isHidden = false })
            .disposed(by: vc.disposeBag)
        vc.searchController.searchBar.rx
            .textDidEndEditing.bind(onNext: { vc.searchHistoryTableView.isHidden = true })
            .disposed(by: vc.disposeBag)

        vc.collectionView.rx.setDelegate(vc).disposed(by: vc.disposeBag)

        var page = 0
        var images = [Image]()

        let resetState = {
            page = 0
            images = []
        }

        let searchText = vc.searchController.searchBar.rx
            .text.asObservable()
            .debounce(.milliseconds(300), scheduler: MainScheduler.instance)
            .do(onNext: { _ in resetState() })
            .compactMap { $0 }


        let scrolledToBottom = vc.collectionView.rx.contentOffset.map {
            $0.y + vc.collectionView.bounds.height + 20 > vc.collectionView.contentSize.height
        }
        .distinctUntilChanged()
        .filter { $0 }.map { _ in }
        .do(onNext: { page += 1 })
        .compactMap { vc.searchController.searchBar.text }

        let search = Observable.merge(searchText, scrolledToBottom)
            .map { ($0, page) }
            .distinctUntilChanged { $0.0 == $1.0 && $0.1 == $1.1 }
            .flatMap { (query, page) -> Observable<[Image]> in
                if query.isEmpty {
                    resetState()
                    return .just([])
                }
                return fetcher.search(query, page:  page)
        }

        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Image>>(configureCell: { _, cv, indexPath, image in
            let cell: ImageCollectionViewCell = cv.dequeue(at: indexPath)
            cell.displayImage(image)

            return cell
        }, configureSupplementaryView: { _, cv, kind, indexPath in
            let footer: ActivityIndicatorReusableView = cv.dequeue(at: indexPath)
            footer.startLoading()

            return footer
        })

        DispatchQueue.main.async {
            search
                .map { newImages in
                    images += newImages
                    return [AnimatableSectionModel<String, Image>(model: "", items: images)]
                }
                .bind(to: vc.collectionView.rx.items(dataSource: dataSource))
                .disposed(by: vc.disposeBag)
        }

        return vc
    }
}

import Differentiator
extension Image: IdentifiableType {
    var identity: Image {
        return Image(id: "\(Int.random(in: 10000...100000))",
            farm: Int.random(in: 10000...100000),
            server: "", secret: "")
    }
}
