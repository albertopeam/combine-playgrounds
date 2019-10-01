import Combine

var subscriptions = Set<AnyCancellable>()

"hey hey there! want to listen to mister mister ?"
    .split(separator: " ")
    .publisher
    .removeDuplicates()
    .collect()
    .sink(receiveValue: { print($0.joined(separator: "  ")) })
    .store(in: &subscriptions)
