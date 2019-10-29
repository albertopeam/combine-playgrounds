import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

// on means publish on thread
// in means mode?,
let publisher = Timer
    .publish(every: 1.0, on: RunLoop.main, in: .common)
    .autoconnect() // starts with first subscription, automatic connection

publisher
    .sink(receiveValue: { print($0) }) // emits the date every second
    .store(in: &subscriptions)

publisher
    .scan(0) { (value, _) -> Int in // starts with an initial value, then it passes the previous value along the date published, we can perform any operation with both data
        value + 1 // in this case we are counting the times dispatched
    }
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

// connect manually
var subscriptions2 = Set<AnyCancellable>()

let publisher2 = Timer
    .publish(every: 1.0, tolerance: 0.5, on: .main, in: .common, options: nil)

publisher2
    .sink(receiveValue: { print("Timer manually started: \($0)") })
    .store(in: &subscriptions2)

DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
    subscriptions.forEach({ $0.cancel() })
    publisher2.connect()
}
