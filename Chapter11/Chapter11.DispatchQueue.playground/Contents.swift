import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()
let queue = DispatchQueue.main
let publisher = PassthroughSubject<Int, Never>()
var counter = 0

// the idea is to create a scheduled action that will trigger publisher events
let cancelable = queue.schedule(after: queue.now, interval: .seconds(1)) {
    publisher.send(counter)
    counter += 1
}

publisher
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
