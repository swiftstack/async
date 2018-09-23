import Time
import Platform

#if canImport(Dispatch)
import struct Dispatch.DispatchQoS
import class Dispatch.DispatchQueue
#endif

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

    #if canImport(Dispatch)
    func syncTask<T>(
        onQueue queue: DispatchQueue,
        qos: DispatchQoS,
        deadline: Time,
        task: @escaping () throws -> T
    ) throws -> T
    #endif

    func sleep(until deadline: Time)

    func wait(for descriptor: Descriptor, event: IOEvent, deadline: Time) throws

    func testCancel() throws
}

public protocol AsyncLoop {
    func run()
    func run(until deadline: Time)
    func terminate()
}

#if canImport(Dispatch)
extension Async {
    public func syncTask<T>(task: @escaping () throws -> T) throws -> T {
        return try syncTask(
            onQueue: DispatchQueue.global(),
            qos: .background,
            deadline: Time.distantFuture,
            task: task)
    }
}
#endif
