import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

let publisher1 = PassthroughSubject<Int, Never>()
let publisher2 = PassthroughSubject<Int, Never>()

publisher1
    .merge(with: publisher2)
    .sink(receiveCompletion: { _ in print("Completed") },
          receiveValue: { print($0) })
    .store(in: &subscriptions)

publisher1.send(1)
publisher2.send(2)
publisher1.send(3)
publisher2.send(4)

publisher1.send(completion: .finished)
publisher2.send(completion: .finished)

print("")

let zero = Future<Int, Never> { (promise) in
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
        promise(.success(0))
    }
}
let first = Just(1).eraseToAnyPublisher()
let second = Just(2).eraseToAnyPublisher()
let third = Just(3).eraseToAnyPublisher()
let fourth = Future<Int, Never> { (promise) in
    promise(.success(4))
}

PassthroughSubject<Int, Never>()
    .print()
    .merge(with: zero, first, second, third, fourth) // merges all elements from diff sources, order depends on submit order and obviously when is the element in time is submitted
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
