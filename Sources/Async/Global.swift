import Platform

var _async: Async!
var registered = false

public var async: Async = {
    guard registered else {
        print("fatal error: async system is not registered, please call " +
            "Async(Fiber/Tarantool)Dispatch().registerGlobal() first")
        exit(1)
    }
    return _async
}()

extension Async {
    @discardableResult
    public func registerGlobal() -> Self {
        guard !(_async is Self) else {
            return self
        }
        guard !registered else {
            fatalError("the global async object was already initialized")
        }
        registered = true
        _async = self
        return self
    }
}
