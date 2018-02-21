import Async
import Dispatch

public struct Dispatch: Asynchronous {
    public static var async: Async {
        return AsyncDispatch()
    }
}
