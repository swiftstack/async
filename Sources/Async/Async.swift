import struct Foundation.Date

public typealias AsyncTask = () -> Void

public protocol Async {
    var loop: AsyncLoop { get }
    var task: (@escaping AsyncTask) -> Void { get }
    var awaiter: IOAwaiter? { get }
}

public protocol AsyncLoop {
    func run()
    func run(until: Date)
}
