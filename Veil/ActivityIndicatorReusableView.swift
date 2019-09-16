import UIKit

final class ActivityIndicatorReusableView: CollectionViewSupplementaryView {
    static let kind = SupplementaryViewKind.footer

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    override func awakeFromNib() {
        super.awakeFromNib()

        activityIndicator.startAnimating()
    }
}
