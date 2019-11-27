import Combine

extension Publisher {
    func unwrap<T>() -> Publishers.CompactMap<Self, T> where Output == Optional<T> {
        compactMap({ $0 })
    }
}

var subscriptions = Set<AnyCancellable>()
[1, nil, 2, nil, 3].publisher
    .unwrap()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
