import Combine

var subscriptions = Set<AnyCancellable>()

let empty = Empty<Int, Never>() // empty creates and Publisher that will end without emmiting any value
empty.replaceEmpty(with: 0) // if subjet finishes without emmiting any value then before finish send the empty value and after finalize
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscriptions)

