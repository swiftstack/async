import Test

@testable import Async

class AsyncTests: TestCase {
    func testAsync() {
        assertTrue(async is AsyncInitializer)
    }
}
