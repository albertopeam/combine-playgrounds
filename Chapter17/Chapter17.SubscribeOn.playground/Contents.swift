import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

let computationPublisher = Publishers.ExpensiveComputation(duration: 3)
let queue = DispatchQueue(label: "serial queue")
let currentThread = Thread.current.number
print("Start computation publisher on thread \(currentThread)")

computationPublisher
    .subscribe(on: queue) // if we use a subscribe(on: queue) we won´t block the current thread, Publisher.ExpensiveComputation blocks thread for a specific amount of time
    .sink { value in
        let thread = Thread.current.number
        print("Received computation result on thread \(thread): '\(value)'")
    }.store(in: &subscriptions)

print("Not blocking on thread \(currentThread)")
