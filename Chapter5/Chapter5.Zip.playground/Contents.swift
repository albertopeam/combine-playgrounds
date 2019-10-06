import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

let publisher1 = PassthroughSubject<Int, Never>()
let publisher2 = PassthroughSubject<String, Never>()

publisher1.zip(publisher2) // both will pair their emissions
    .print()
    .sink(receiveCompletion: { print($0) },
      receiveValue: { print("P1: \($0), P2: \($1)") })
    .store(in: &subscriptions)

publisher1.send(1)
publisher1.send(2)
publisher2.send("a")
publisher2.send("b")
publisher1.send(3)
publisher2.send("c")
publisher2.send("d") // from here onwards none of the sends will do something because we don´t have a full tuple from both publishers, only publisher2 is sending data.
publisher2.send("e")
publisher2.send("f")

publisher1.send(completion: .finished) // when any of then finishes then zip finishes
publisher2.send(completion: .finished)


print("")

struct Move {
    let column: Int
    let file: String
}

let future = Future<Int, Never> { (promise) in
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.001) {
        promise(.success(1))
    }
}.eraseToAnyPublisher()

let just = Just("a").eraseToAnyPublisher()

just.zip(future) // it will emit a tuple of both values sended
    .print()
    .map({ Move(column: $0.1, file: $0.0) })
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
