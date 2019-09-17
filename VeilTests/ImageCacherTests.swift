@testable import Veil
import XCTest

final class ImageCacherTestCase: XCTestCase {

    var subject: ImageCacher!
    var storage: MockStorage!

    override func setUp() {
        super.setUp()

        storage = MockStorage()

        AppEnvironment.current.storage = storage

        subject = ImageCacher()
    }

    func test_save_eventuallyCreatesFileWithData() {
        // GIVEN
        let name = "someImageName"

        // WHEN
        subject.save(Data(), named: name)

        // THEN
        wait(for: [storage.createFileAtPath], timeout: 3)
    }

    func test_retrieve_whenImageIsAlreadySaved_ReturnsItWithoutReadingStorage() {
        // GIVEN
        let name = "randomImageName"
        let data = "someRandomData".data(using: .utf8)!
        subject.save(data, named: name)
        let correctImageReturned = XCTestExpectation(description: "Correct image was returned")

        // WHEN
        subject.retrieve(named: name) { imageData in
            if imageData == data { correctImageReturned.fulfill() }
        }

        // THEN
        wait(for: [correctImageReturned], timeout: 3)
        XCTAssertFalse(storage.contentsAtPathCalled)
    }

    func test_retrieve_readsContentsAtCorrectPathAndReturnsThem() {
        // GIVEN
        let name = "randomImageName"
        let data = "someRandomData".data(using: .utf8)!
        storage.fileExistsStub = true
        let correctImageReturned = XCTestExpectation(description: "Correct image was returned")
        storage.contentsAtPathStub = data

        // WHEN
        subject.retrieve(named: name) { imageData in
            if imageData == data { correctImageReturned.fulfill() }
        }

        // THEN
        wait(for: [correctImageReturned], timeout: 3)
        XCTAssert(storage.contentsAtPathCalled)
        XCTAssertEqual(storage.contentsAtPathCalledPath,
                       storage.documentsDirectory.appendingPathComponent("Images").appendingPathComponent("\(name).jpg").path)
    }
}
