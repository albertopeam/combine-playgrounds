import Combine

var subscription = Set<AnyCancellable>()

["a", "1", "3.1"].publisher
    .compactMap({ Float($0) })
    .sink(receiveValue: { print($0)})
    .store(in: &subscription)
