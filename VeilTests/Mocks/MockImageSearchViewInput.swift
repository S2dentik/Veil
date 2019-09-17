@testable import Veil
import Foundation

final class MockImageSearchViewInput: ImageSearchViewInput {

    var displayErrorCalledError: String?
    var displayErrorCalled = false
    func displayError(_ error: String) {
        displayErrorCalled = true
        displayErrorCalledError = error
    }

    var insertAtIndexPathsCalledIndexPaths: [IndexPath]?
    var insertAtIndexPathsCalled = false
    func insert(at indexPaths: [IndexPath]) {
        insertAtIndexPathsCalled = true
        insertAtIndexPathsCalledIndexPaths = indexPaths
    }

    var deleteAtIndexPathsCalledIndexPaths: [IndexPath]?
    var deleteAtIndexPathsCalled = false
    func delete(at indexPaths: [IndexPath]) {
        deleteAtIndexPathsCalled = true
        deleteAtIndexPathsCalledIndexPaths = indexPaths
    }
}
