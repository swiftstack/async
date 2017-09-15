import Platform

import struct Foundation.Date
import struct Dispatch.DispatchQoS
import class Dispatch.DispatchQueue

public enum IOEvent {
    case read, write
}

public typealias AsyncTask = () -> Void

public enum AsyncError: Error {
    case timeout
    case taskCanceled
}

public protocol Async {
    var loop: AsyncLoop { get }

    func task(_ closure: @escaping AsyncTask) -> Void

    func syncTask<T>(
        onQueue queue: DispatchQueue,
        qos: DispatchQoS,
        deadline: Date,
        task: @escaping () throws -> T
    ) throws -> T

    func sleep(until deadline: Date)

    func wait(for descriptor: Descriptor, event: IOEvent, deadline: Date) throws

    func testCancel() throws
}

public protocol AsyncLoop {
    func run()
    func run(until: Date)
    func terminate()
}

extension Async {
    public func syncTask<T>(task: @escaping () throws -> T) throws -> T {
        return try syncTask(
            onQueue: DispatchQueue.global(),
            qos: .background,
            deadline: Date.distantFuture,
            task: task)
    }
}
