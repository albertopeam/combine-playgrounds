import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

let computationPublisher = Publishers.ExpensiveComputation(duration: 3)
let queue = DispatchQueue(label: "serial queue")
let currentThread = Thread.current.number
print("Start computation publisher on thread \(currentThread)")

computationPublisher
    .subscribe(on: queue) // execute in background queue
    .receive(on: RunLoop.main) // dispatch in main queue
    .sink { value in
        let thread = Thread.current.number
        print("Received computation result on thread \(thread): '\(value)'")
    }.store(in: &subscriptions)
