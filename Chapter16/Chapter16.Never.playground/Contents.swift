import Combine

var subscriptions: Set<AnyCancellable> = .init()

Just([1, 2, 3, 4, 5])
    .flatMap({ (items) in items.publisher })
    .sink(receiveValue: { print($0) }) //this kind of sink only receive values, this way we can ignore completion event
    .store(in: &subscriptions)
