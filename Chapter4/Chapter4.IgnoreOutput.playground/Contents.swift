import Combine

var subscription = Set<AnyCancellable>()

let subject = PassthroughSubject<Int, Never>()
subject.ignoreOutput()
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscription)

subject.send(1) // never received by subscribers
subject.send(completion: .finished)
