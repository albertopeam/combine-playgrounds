import Combine

class StringSubscriber: Subscriber {
    typealias Input = String
    typealias Failure = Error
    
    enum Error: Swift.Error { case anyone }
    
    func receive(subscription: Subscription) {
        subscription.request(.max(5))
    }
    
    func receive(_ input: String) -> Subscribers.Demand {
        print("receive \(input)")
        return input == "World" ? .max(1) : .none
    }
    
    func receive(completion: Subscribers.Completion<StringSubscriber.Error>) {
        print("completion \(completion)")
    }
}

let subscriber = StringSubscriber()

let subject = PassthroughSubject<String, StringSubscriber.Error>()
subject.subscribe(subscriber)
let subscription = subject.sink(receiveCompletion: { (completion) in
    print("sink completion \(completion)")
}) { (output) in
    print("sink output \(output)")
}
subject.send("Hello")
subject.send("World")

subscription.cancel() // cancel sink subscription
subject.send("Ou mama") // it won´t be received by sink subscription

subject.send(completion: .finished)
subject.send("World") // no new events are admited once the subject is finished or have an error

subject.send(completion: .failure(.anyone)) // no new events(finish and failure) are admited after completion is invoked


