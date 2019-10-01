import Combine

var subscription = Set<AnyCancellable>()

[1, 2, 3, 4].publisher
    .print()
    .first(where: { $0 % 2 == 0 })
    .sink(receiveCompletion: { print("Completed with: \($0)") },
          receiveValue: { print($0) })
    .store(in: &subscription)
