import UIKit

protocol ImageCollectionViewCellDelegate: class {
    func handleError(_ error: String)
}

final class ImageCollectionViewCell: CollectionViewCell {
    
    @IBOutlet private var imageView: UIImageView!
    weak var delegate: ImageCollectionViewCellDelegate?

    private var currentTask: NetworkTask?

    override func awakeFromNib() {
        super.awakeFromNib()

        contentView.backgroundColor = .lightGray
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()

        contentView.backgroundColor = .lightGray
        imageView.layer.removeAllAnimations()
        currentTask?.cancel()
        imageView.image = nil
    }

    func displayImage(_ image: Image) {
        AppEnvironment.cacher.retrieve(named: image.id, completionQueue: .main) { [weak self] cachedData in
            if let data = cachedData {
                self?.setImageAnimatedly(UIImage(data: data))
            } else {
                self?.fetchImage(image)
            }
        }
    }

    private func fetchImage(_ image: Image) {
        currentTask = AppEnvironment.network.dataTask(with: image.url) { [weak self] result in
            switch result {
            case .success(let data):
                UI {
                    AppEnvironment.cacher.save(data, named: image.id)
                    self?.setImageAnimatedly(UIImage(data: data))
                }
            case .failure(let error):
                self?.delegate?.handleError(error.localizedDescription)
            }
        }
        currentTask?.resume()
    }

    private func setImageAnimatedly(_ image: UIImage?) {
        contentView.backgroundColor = .clear
        imageView.image = image
        let transition = CATransition()
        transition.duration = 0.5
        transition.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        transition.type = .fade
        imageView.layer.add(transition, forKey: nil)
    }
}
