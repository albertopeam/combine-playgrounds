import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()
let queue = OperationQueue()

queue.publisher(for: \.operationCount) // KVO observing using publisher
    .print()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

queue.addOperation {
    print("Added Op.")
}
