import UIKit

extension UIView {
    func embedSubview(_ view: UIView) {
        [
            topAnchor.constraint(equalTo: view.topAnchor),
            bottomAnchor.constraint(equalTo: view.bottomAnchor),
            leftAnchor.constraint(equalTo: view.leftAnchor),
            rightAnchor.constraint(equalTo: view.rightAnchor)
        ].forEach { $0.constant = 0 }
        addSubview(view)
    }
}
