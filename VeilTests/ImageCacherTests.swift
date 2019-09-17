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
}
