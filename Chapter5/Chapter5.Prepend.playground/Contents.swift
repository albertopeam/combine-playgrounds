import Combine

var suscriptions = Set<AnyCancellable>()

[3, 4, 5].publisher
    .prepend(1, 2) // variadic version
    .prepend(-1, 0) // multiple prepends will be attached at the begining
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &suscriptions)

print("")

[3, 4, 5].publisher
    .prepend([1, 2]) // sequence version
    .prepend(Set(-1...0)) // also with a set, IMPORTANT: order in sets are not guaranteed, so it can be -1,0 OR 0,1 for this case
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &suscriptions)

print("")

let sequence = stride(from: 0, to: 10, by: 2)
[10].publisher
    .prepend(sequence) // sequence created with stride
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &suscriptions)

print("")

let startPublisher = [0, 1, 2, 3].publisher
[4, 5, 6, 7, 8, 9].publisher
    .prepend(startPublisher) // prepends the data of the startPublisher to the current publisher
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &suscriptions)

print("")

let subject = PassthroughSubject<Int, Never>()
[0, 1, 2, 3].publisher
    .prepend(subject.eraseToAnyPublisher())
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &suscriptions)

subject.send(-2)
subject.send(-1)
//subject.send(completion: .finished)
// the order is -2, -1, 0, 1, 2, 3(as expected: first prepend, then the rest) but the publisher wont emit its initial values(0, 1, 2, 3) until completion is sended on subject because it needs to know that no more values will be prepended
