import Combine

var subscriptions = Set<AnyCancellable>()
let subject = CurrentValueSubject<String, Never>("")

let publisher = subject.eraseToAnyPublisher() // hide details about the concrete publisher downstream to the subscribers
publisher.print()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

// publisher.value = "Compilation error due to `eraseToAnyPublisher`"
// publisher.send("Ho") // it wont compile because its type is erased

subject.send("Hi!")
subscriptions.forEach({ $0.cancel() })

//The idea is to be able to send values where the subject is accesible and in the other side(publisher) to be able to listen events, so separation of concerns


