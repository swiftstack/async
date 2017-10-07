@_exported import Async

import Platform
import Dispatch
import Foundation

public struct AsyncDispatch: Async {
    public init() {}

    public var loop: AsyncLoop = Loop()

    public func task(_ closure: @escaping AsyncTask) -> Void {
        DispatchQueue.global(qos: .userInitiated).async(execute: closure)
    }

    public func syncTask<T>(
        onQueue queue: DispatchQueue = DispatchQueue.global(),
        qos: DispatchQoS = .background,
        deadline: Date = Date.distantFuture,
        task: @escaping () throws -> T
    ) throws -> T {
        var result: T? = nil
        var error: Error? = nil

        let workItem = DispatchWorkItem(qos: qos) {
            do {
                result = try task()
            } catch let taskError {
                error = taskError
            }
        }

        queue.async(execute: workItem)

        let timeout: DispatchTime
        switch deadline {
        case Date.distantFuture:
            timeout = .distantFuture
        default:
            let date = Date()
            if date > deadline {
                timeout = DispatchTime.now()
            } else {
                let interval = deadline.timeIntervalSince(date)
                let nanoseconds = UInt64(interval * 1_000_000_000)
                let now = DispatchTime.now().uptimeNanoseconds
                timeout = DispatchTime(uptimeNanoseconds: now + nanoseconds)
            }
        }

        switch workItem.wait(timeout: timeout) {
        case .timedOut: throw AsyncError.timeout
        default: break
        }

        if let error = error {
            throw error
        } else if let result = result {
            return result
        } else {
            fatalError("unexpected result")
        }
    }

    // Just a plug.
    public func wait(
        for descriptor: Descriptor,
        event: IOEvent,
        deadline: Date
    ) throws {
        let event = event == .read ? Int16(POLLIN) : Int16(POLLOUT)
        var fd = pollfd(fd: descriptor.rawValue, events: event, revents: 0)

        func calculateTimeout(to deadline: Date) throws -> Int32 {
            let indefinitely: Int32 = -1

            switch deadline {
            case .distantFuture:
                return indefinitely
            default:
                let timeInterval = Int(deadline.timeIntervalSinceNow * 1_000)
                guard timeInterval <= Int32.max else {
                    return indefinitely
                }
                guard timeInterval > 0 else {
                    throw AsyncError.timeout
                }
                return Int32(timeInterval)
            }
        }

        while true {
            let timeout = try calculateTimeout(to: deadline)
            let result = poll(&fd, 1, timeout)
            if result == -1 && errno == EINTR {
                continue
            }
            guard result <= 0 else {
                break
            }
            switch result {
            case 0: throw AsyncError.timeout
            default: throw SystemError()
            }
        }
    }

    public func sleep(until deadline: Date) {
        let interval = deadline.timeIntervalSinceNow
        let seconds = Int(interval)
        let nanoseconds = Int((interval - Double(seconds)) * 1_000_000_000)
        var time = timespec(tv_sec: seconds, tv_nsec: nanoseconds)
        nanosleep(&time, nil)
    }

    public func testCancel() throws {
        if Thread.current.isCancelled {
            throw AsyncError.taskCanceled
        }
    }
}

extension AsyncDispatch {
    public class Loop: AsyncLoop {
        var terminated = false

        public func run() {
            while !terminated {
                _ = RunLoop.current.run(
                    mode: .defaultRunLoopMode,
                    before: Date(timeIntervalSinceNow: 0.005))
            }
        }

        public func run(until date: Date) {
            while !terminated && Date() < date {
                _ = RunLoop.current.run(
                    mode: .defaultRunLoopMode,
                    before: date)
            }
        }

        public func terminate() {
            terminated = true
        }
    }
}
