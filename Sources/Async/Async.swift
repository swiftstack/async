import struct Foundation.Date
import struct Dispatch.DispatchQoS

public typealias AsyncTask = () -> Void

public protocol Async {
    var loop: AsyncLoop { get }
    var awaiter: IOAwaiter? { get }

    func task(_ closure: @escaping AsyncTask) -> Void

    func syncTask<T>(
        qos: DispatchQoS.QoSClass,
        deadline: Date,
        task: @escaping () throws -> T
    ) throws -> T
}

public protocol AsyncLoop {
    func run()
    func run(until: Date)
}
