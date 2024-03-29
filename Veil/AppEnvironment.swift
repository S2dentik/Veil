import Foundation
import RxSwift

final class AppEnvironment {
    static var current: Environment {
        let environment = environments.last ?? Environment()
        if environments.isEmpty {
            environments.append(environment)
        }
        return environment
    }

    private static var environments = [Environment()]
}

extension AppEnvironment {
    static var storage: Storage {
        return current.storage
    }

    static var network: Network {
        return current.network
    }

    static var cacher: Cacher {
        return current.cacher
    }
}

class Environment {
    var storage: Storage = FileManager.default
    var network: Network = URLSession.shared.rx
    var cacher: Cacher = ImageCacher()
}
