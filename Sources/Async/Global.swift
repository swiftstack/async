public var async: Async!

var registered = false

extension Async {
    @discardableResult
    public func registerGlobal() -> Self {
        guard !registered else {
            fatalError("the global async object was already initialized")
        }
        registered = true
        async = self
        return self
    }
}
