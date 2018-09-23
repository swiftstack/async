// - A complete hack just to have much nicer API:
//
// async.use(Fiber.self)
//
// - instead of:
//
// AsyncFiber.registerGlobal()

public protocol Asynchronous {
    static var async: Async { get }
}

extension Async {
    public func use(_ system: Asynchronous.Type) {
        async = system.async
    }

    /// @testable
    func setUp(_ system: Asynchronous.Type) {
        guard !initialized else {
            // allow to run tests with the same async
            if type(of: async) != type(of: system.async) {
                fatalError("async: conflict")
            }
            return
        }
        use(system)
    }
}

import Time
import Platform

#if canImport(Dispatch)
import struct Dispatch.DispatchQoS
import class Dispatch.DispatchQueue
#endif

struct AsyncInitializer: Async {
    var loop: AsyncLoop {
        die()
    }

    func die() -> Never {
        print("fatal error: async system is not registered")
        print("please call `async.use(Fiber(Tarantool).self)` first")
        exit(1)
    }

    func task(_ closure: @escaping AsyncTask) {
        die()
    }

    #if canImport(Dispatch)
    func syncTask<T>(
        onQueue queue: DispatchQueue,
        qos: DispatchQoS,
        deadline: Time,
        task: @escaping () throws -> T) throws -> T
    {
        die()
    }
    #endif

    func sleep(until deadline: Time) {
        die()
    }

    func wait(
        for descriptor: Descriptor,
        event: IOEvent,
        deadline: Time) throws
    {
        die()
    }

    func testCancel() throws {
        die()
    }
}
