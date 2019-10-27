import UIKit
import RxSwift
import RxCocoa
import RxDataSources

protocol ImageSearchView {
    var scrolledToBottom: Observable<Void> { get }
    var search: BehaviorRelay<String> { get }
    var searchFinished: Observable<Void> { get }
}

final class ImageSearchViewController: UIViewController, ImageSearchView, StoryboardInstantiable {

    static let storyboardName = "Main"

    let disposeBag = DisposeBag()
    var model: ImageSearchViewModelType!
    
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var searchHistoryTableView: UITableView!
    var searchController: UISearchController!

    fileprivate let interitemSpacing: CGFloat = 10
    fileprivate let sectionInsets: CGFloat = 10
    fileprivate let numberOfItemsInRow = 2

    private var searchBarText: String {
        get {
            searchController.searchBar.text ?? ""
        }
        set {
            searchController.searchBar.text = newValue
            searchController.searchBar.endEditing(true)
        }
    }

    lazy var scrolledToBottom: Observable<Void> = {
        collectionView.rx.contentOffset
            .map { $0.y + self.collectionView.bounds.height + 20 > self.collectionView.contentSize.height }
            .distinctUntilChanged()
            .filter { $0 }.map { _ in }
    }()
    lazy var searchFinished = searchController.searchBar.rx.textDidEndEditing.asObservable()
    let search = BehaviorRelay<String>(value: "")

    override func viewDidLoad() {
        super.viewDidLoad()

        searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.autocapitalizationType = .none
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
        definesPresentationContext = true

        searchHistoryTableView.register(UITableViewCell.self)
        collectionView.register(ImageCollectionViewCell.self)
        collectionView.register(ActivityIndicatorReusableView.self)

        setup()
    }

    private func setup() {
        collectionView.rx.setDelegate(self).disposed(by: disposeBag)
        searchController.searchBar.rx.text.orEmpty.bind(to: search).disposed(by: disposeBag)
        searchController.searchBar.rx.cancelButtonClicked.map { "" }.bind(to: search).disposed(by: disposeBag)

        searchController.searchBar.rx
            .textDidBeginEditing.bind(onNext: { [weak self] in self?.searchHistoryTableView.isHidden = false })
            .disposed(by: disposeBag)

        searchFinished
            .subscribe(onNext: { [weak self] in self?.searchHistoryTableView.isHidden = true })
            .disposed(by: disposeBag)

        search
            .subscribe(onNext: { [weak self] _ in self?.collectionView.contentOffset = .zero })
            .disposed(by: disposeBag)

        searchHistoryTableView.rx.itemSelected.asObservable()
            .compactMap { [weak self] in self?.model.pastSearches.value[$0.item] }
            .subscribe(onNext: { [weak self] in self?.searchBarText = $0 })
            .disposed(by: disposeBag)
    }
}

extension ImageSearchViewController {
    func bind(to viewModel: ImageSearchViewModelType) {
        self.model = viewModel
        _ = view

        search.asObservable()
            .flatMap { [weak self] query -> Observable<[String]> in
                let searches = self?.model.pastSearches.asObservable() ?? .empty()
                if query.isEmpty { return searches } // "Cat".contains("") returns false
                return searches.map { $0.filter { $0.contains(query) }}
            }
            .bind(to: searchHistoryTableView.rx.items(cellIdentifier: UITableViewCell.identifier,
                                                    cellType: UITableViewCell.self)) { _, item, cell in
                                                        cell.textLabel?.text = item
            }
            .disposed(by: disposeBag)

        let dataSource = RxCollectionViewSectionedAnimatedDataSource<AnimatableSectionModel<String, Image>>(configureCell: { [weak model] _, cv, indexPath, image in
            let cell: ImageCollectionViewCell = cv.dequeue(at: indexPath)
            cell.image = model?.data(for: image).map(UIImage.init).compactMap { $0 }

            return cell
        }, configureSupplementaryView: { _, cv, kind, indexPath in
            let footer: ActivityIndicatorReusableView = cv.dequeue(at: indexPath)
            footer.startLoading()

            return footer
        })

        model.images
            .map { [AnimatableSectionModel<String, Image>(model: "", items: $0)] }
            .bind(to: collectionView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

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
