import Combine

var subscriptions = Set<AnyCancellable>()

[1, 2, 3, 4, 5]
    .publisher
    .dropFirst() // drops the first element at the begining
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscriptions)


(0...9)
    .publisher
    .dropFirst(5) // drops five elements at the begining
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscriptions)

