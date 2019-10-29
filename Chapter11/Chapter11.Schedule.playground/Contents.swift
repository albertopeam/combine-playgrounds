import Combine
import Foundation

let runLoop = RunLoop.main

let cancelable = runLoop
    .schedule(after: runLoop.now, interval: .seconds(1), tolerance: .milliseconds(100), options: nil) {
    print("Schedule fired") // it fires every interval the action block
}
DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    cancelable.cancel()
}

let oneSecInTheFuture = Date().addingTimeInterval(TimeInterval(1))
let after = RunLoop.SchedulerTimeType(oneSecInTheFuture)
print(Date())
runLoop.schedule(after: after) {
    print("Schedule \(Date())") //fires only once after the specified time, not cancelable
}

