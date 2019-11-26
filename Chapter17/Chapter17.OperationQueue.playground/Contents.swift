import Combine
import Foundation

var subs = Set<AnyCancellable>()

let queue = OperationQueue() // it uses Dispatch under the hood, so similar behaviour to concurrent DispatchQueue
//queue.maxConcurrentOperationCount = 1 // if we limit to 1 thread the values will be emitted in order. equivalent to use a serial DispatchQueue

(1...10).publisher
    .receive(on: queue) // the items won´t be published in order due to the  multithreading. It doesn´t guarantee the same thread for each emitted value
    .sink(receiveValue: { print("Received \($0) on thread \(Thread.current.number)") })
    .store(in: &subs)
