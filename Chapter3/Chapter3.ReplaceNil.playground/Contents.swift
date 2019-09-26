import Combine

var subscriptions = Set<AnyCancellable>()

[nil, "data", nil, "new"].publisher
    .replaceNil(with: "placeholder") // it forces you to send a non optional
    .compactMap({ $0 }) // as the publisher is a [String?] using `replaceNil` doesn´t change that downstream, so we must use a compactMap to filter nil values
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
