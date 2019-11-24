import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

let concurrentQueue = DispatchQueue(label: "parallel queue", attributes: .concurrent)
let computationPublisher = Publishers.ExpensiveComputation(duration: 3)
let currentThread = Thread.current.number
print("Start computation publisher on thread \(currentThread)")

(0...3).forEach { iteration in
    computationPublisher
        .subscribe(on: concurrentQueue) //multiple threads available
        .sink { value in
            let thread = Thread.current.number
            print("Received computation result on thread \(thread): '\(value)'. iteration: \(iteration)")
        }.store(in: &subscriptions)
}
