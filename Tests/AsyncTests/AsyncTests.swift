import Test

@testable import Async

class AsyncTests: TestCase {
    func testAsync() {
        expect(async is AsyncInitializer)
    }
}
