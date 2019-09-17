import UIKit

protocol StoryboardInstantiable: Identifiable {
    static var storyboardName: String { get }
}

extension StoryboardInstantiable {
    static func instantiate() -> Self {
        let storyboard = UIStoryboard(name: storyboardName, bundle: nil)

        return storyboard.instantiateViewController(withIdentifier: identifier) as! Self
    }
}
