import Combine

var subscriptions = Set<AnyCancellable>()

[1, 2, 3, 4, 5]
    .publisher
    .prefix(2) // it let pass two elements and then finishes
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscriptions)
