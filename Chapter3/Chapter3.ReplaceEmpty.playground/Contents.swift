import Combine

var subscriptions = Set<AnyCancellable>()

let subject = PassthroughSubject<Int, Never>()
subject.replaceEmpty(with: 0) // if subjet finishes without emmiting any value then before finish send the empty value and after finalize
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscriptions)

subject.send(completion: .finished)

