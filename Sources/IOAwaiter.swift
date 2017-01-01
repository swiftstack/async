import Platform

public enum IOEvent {
    case read, write
}

public protocol IOAwaiter {
    func wait(for descriptor: Descriptor, event: IOEvent) throws
}
