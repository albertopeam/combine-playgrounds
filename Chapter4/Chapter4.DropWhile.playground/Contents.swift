import Combine

var subscriptions = Set<AnyCancellable>()

[true, true, true, false, true]
    .publisher
    .drop(while: { $0 == true }) // drops elements until the predicate is true(the opposite of `filter`). once the predicate is true it won´t be evaluated for next values, they will be published all of them
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscriptions)
