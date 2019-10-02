import Combine

var subscriptions = Set<AnyCancellable>()

[2, 4, 6, 8, 9]
    .publisher
    .prefix(while: { $0 % 2 == 0}) // it lets pass elements while even, then finishes
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscriptions)
