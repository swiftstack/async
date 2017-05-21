import Platform
import struct Foundation.Date

public enum IOEvent {
    case read, write
}

public protocol IOAwaiter {
    func wait(for descriptor: Descriptor, event: IOEvent, deadline: Date) throws
}
