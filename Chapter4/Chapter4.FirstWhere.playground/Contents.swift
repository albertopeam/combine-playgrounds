import Combine

var subscription = Set<AnyCancellable>()

[1, 2, 3, 4].publisher
    .print()
    .first(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscription)

// First where will finish the subscription if the condition is true for any of the values sended
let publisher = PassthroughSubject<Int, Never>()
publisher.print()
    .first(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscription)
publisher.send(1)
publisher.send(3)
publisher.send(2)
publisher.send(2)
publisher.send(3)

// publisher.send(completion: .finished) // not needed if any value makes the predicate true
