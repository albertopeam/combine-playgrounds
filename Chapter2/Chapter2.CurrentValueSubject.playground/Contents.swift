import Combine

var subscriptions = Set<AnyCancellable>()

let subject = CurrentValueSubject<Int, Never>(0)
subject
    .print() // it will log any activity
    .sink(receiveCompletion: { (completion) in
    print("completion \(completion)")
}) { (output) in
    print("output \(output)")
}
.store(in: &subscriptions)

// subscriptions.forEach({ $0.cancel() }) // cancel will cancel all sends or values posted to the subject

subject.send(1)
subject.send(3)
subject.send(14)

print(subject.value) // it will print the last value sended to the subject

subject.value = 5 // another way of assign a value

//subject.value = .finished // not valid, the way is to use `send`

subject.send(completion: .finished)

subject.value = 77 // no more events after finish or error
