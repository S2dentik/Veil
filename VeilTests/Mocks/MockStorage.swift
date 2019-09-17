@testable import Veil
import Foundation
import XCTest

class MockStorage: Storage {

    var documentsDirectory = URL(string: "documentsDirectory")!

    var fileExistsStub = false
    var fileExistsCalled = false
    func fileExists(atPath path: String) -> Bool {
        fileExistsCalled = true

        return fileExistsStub
    }

    var contentsAtPathStub: Data?
    var contentsAtPathCalled = false
    func contents(atPath path: String) -> Data? {
        contentsAtPathCalled = true

        return contentsAtPathStub
    }

    var createFileAtPathCalled = false
    var createFileAtPath = XCTestExpectation(description: "Create file at path called")
    var createFileAtPathCalledPath = ""
    var createFileAtPathCalledData: Data?
    func createFile(atPath path: String, contents data: Data?) {
        createFileAtPath.fulfill()
        createFileAtPathCalled = true
        createFileAtPathCalledData = data
        createFileAtPathCalledPath = path
    }
}
