import Platform

private var initialized = false
@_versioned var _async: Async = AsyncInitializer()

public var async: Async {
    @inline(__always) get {
        return _async
    }
    set {
        guard !initialized else {
            fatalError("the global async object has already been initialized")
        }
        initialized = true
        _async = newValue
    }
}
