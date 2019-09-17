import Foundation

func UI(_ block: @escaping () -> Void) {
    if Thread.current.isMainThread { return block() }
    DispatchQueue.main.async(execute: block)
}
