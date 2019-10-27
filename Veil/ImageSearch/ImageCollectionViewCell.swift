import UIKit
import RxSwift

final class ImageCollectionViewCell: CollectionViewCell {
    
    @IBOutlet private var imageView: UIImageView!

    private var disposeBag = DisposeBag()
    var image: Observable<UIImage>? {
        didSet {
            image?
                .observeOn(MainScheduler.instance)
                .do(onNext: { [weak self] _ in self?.contentView.backgroundColor = .clear })
                .bind(to: imageView.rx.image).disposed(by: disposeBag)
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .lightGray
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        contentView.backgroundColor = .lightGray
        imageView.image = nil
        disposeBag = DisposeBag()
    }
}
