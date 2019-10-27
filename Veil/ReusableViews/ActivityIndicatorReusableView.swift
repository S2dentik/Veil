import UIKit

final class ActivityIndicatorReusableView: CollectionViewSupplementaryView {
    static let kind = SupplementaryViewKind.footer

    @IBOutlet var activityIndicator: UIActivityIndicatorView!

    func startLoading() {
        activityIndicator.startAnimating()
    }
}
