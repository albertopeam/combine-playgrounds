import Combine

var subscription = Set<AnyCancellable>()

[1, 2, 3, 4, 5].publisher
    .print()
    .last(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscription)

// last where needs to the publisher to emit the final signal to be able to produce a result if it exist

let publisher = PassthroughSubject<Int, Never>()
publisher
    .print()
    .last(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
      receiveValue: { print($0) })
    .store(in: &subscription)
publisher.send(10)
publisher.send(21)
publisher.send(31)
publisher.send(41)

// it doesn´t send value until the publisher is finished

publisher.send(completion: .finished) // commenting this line makes the publisher to not finish
