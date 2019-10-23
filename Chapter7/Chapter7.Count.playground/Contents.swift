import Combine

var subscriptions = Set<AnyCancellable>()

let items = [1, 2, 3, 5, 7, 11, 13]

items.publisher
    .print()
    .count() // count won´t finish until finish event is sent
    .sink(receiveValue: { print("Num. items: \($0)") })
    .store(in: &subscriptions)
