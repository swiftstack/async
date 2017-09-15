import Test
import Dispatch
import Foundation

@testable import AsyncDispatch

class AsyncDispatchTests: TestCase {
    func testTask() {
        let async = AsyncDispatch()
        let condition = DispatchSemaphore(value: 0)

        var done = false
        async.task {
            done = true
            condition.signal()
        }

        condition.wait()
        assertTrue(done)
    }

    func testSyncTask() {
        let async = AsyncDispatch()

        var done = false
        let result: Int? = try? async.syncTask {
            done = true
            return 42
        }

        assertTrue(done)
        assertEqual(result, 42)
    }

    func testSyncTaskTimeout() {
        let async = AsyncDispatch()

        var done = false
        let task = {
            async.sleep(until: Date(timeIntervalSinceNow: 0.2))
            done = true
        }

        assertThrowsError(try async.syncTask(
            deadline: Date(timeIntervalSinceNow: 0.1),
            task: task
        )) { error in
            assertEqual(error as? AsyncError, .timeout)
        }

        assertFalse(done)
    }

    func testSyncTaskCancel() {
        let async = AsyncDispatch()

        var taskDone = false
        var syncTaskDone = false

        var error: Error? = nil

        async.task {
            assertNotNil(try? async.testCancel())
            Thread.current.cancel()
            assertNil(try? async.testCancel())
        }

        async.task {
            do {
                try async.syncTask {
                    Thread.current.cancel()
                    try async.testCancel()
                    syncTaskDone = true
                }
            } catch let taskError {
                error = taskError
            }

            taskDone = true
        }

        async.loop.run(until: Date().addingTimeInterval(0.1))

        assertEqual(error as? AsyncError, .taskCanceled)
        assertTrue(taskDone)
        assertFalse(syncTaskDone)
    }
}
