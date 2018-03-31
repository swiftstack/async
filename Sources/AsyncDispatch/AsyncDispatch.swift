@_exported import Async

import Time
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
        deadline: Time = .distantFuture,
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
        case Time.distantFuture:
            timeout = .distantFuture
        default:
            if deadline < .now {
                timeout = DispatchTime.now()
            } else {
                let duration = deadline.timeIntervalSinceNow.duration
                let nanoseconds = UInt64(duration.ns)
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
        deadline: Time
    ) throws {
        let event = event == .read ? Int16(POLLIN) : Int16(POLLOUT)
        var fd = pollfd(fd: descriptor.rawValue, events: event, revents: 0)

        func calculateTimeout(_ now: Time, _ deadline: Time) throws -> Int32 {
            guard deadline < .distantFuture else {
                return -1
            }
            let timeout = deadline.timeIntervalSinceNow.duration.ms
            guard timeout < Int32.max else {
                return -1
            }
            return Int32(timeout)
        }

        while true {
            let now: Time = .now
            guard deadline > now else {
                throw AsyncError.timeout
            }
            let result = poll(&fd, 1, try calculateTimeout(now, deadline))
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

    public func sleep(until deadline: Time) {
        let duration = deadline.timeIntervalSinceNow.duration
        var time = timespec(
            tv_sec: duration.seconds,
            tv_nsec: duration.nanoseconds)
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

        public func run(until deadline: Time) {
            while !terminated && .now < deadline {
                let duration = deadline.timeIntervalSinceNow.duration
                let timeInterval = Double(duration.ms) / 1000
                let date = Date().addingTimeInterval(timeInterval)

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
