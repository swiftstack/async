# Async

An abstraction over coroutine-based io poller and asynchronous task.

This design allows us to easily swap our fiber system to [another one](https://github.com/swift-stack/tarantool) provided by the host application.

## Package.swift

```swift
.package(url: "https://github.com/swift-stack/async.git", .branch("dev"))
```

## Usage

async.main is just a wrapper around async.task to hide `do {} catch {}`

```swift
import Fiber

async.use(Fiber.self)

async.main {
    async.task {
        async.sleep(until: .now)
    }
}

async.loop.run()
```
