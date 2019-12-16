import Combine
import Foundation

protocol Pausable {
    var paused: Bool { get }
    func resume()
}

final class PausableSubscriber<Input, Failure: Error>: Subscriber, Pausable, Cancellable {
    let combineIdentifier = CombineIdentifier() // provide a unique identifier for Combine to manage and optimize its publisher streams.
    var paused: Bool = false
    private let receiveValue: (Input) -> Bool
    private let receiveCompletion: (Subscribers.Completion<Failure>) -> Void
    private var subscription: Subscription? = nil

    init(receiveValue: @escaping (Input) -> Bool, receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) {
        self.receiveValue = receiveValue
        self.receiveCompletion = receiveCompletion
    }

    func resume() {
        guard paused else { return }
        paused = false
        subscription?.request(.max(1))
    }

    func cancel() {
        subscription?.cancel()
        subscription = nil
    }

    func receive(subscription: Subscription) {
        self.subscription = subscription
        subscription.request(.max(1))
    }

    func receive(_ input: Input) -> Subscribers.Demand {
        paused = receiveValue(input) == false
        return paused ? .none: .max(1)
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        receiveCompletion(completion)
        subscription = nil
    }
}

extension Publisher {
    func pausableSink(receiveValue: @escaping (Output) -> Bool,
                      receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void) -> Pausable & Cancellable {
        let subscriber = PausableSubscriber(receiveValue: receiveValue, receiveCompletion: receiveCompletion)
        subscribe(subscriber)
        return subscriber
    }
}

let subject = PassthroughSubject<Int, Never>()
let pausable = subject
    .pausableSink(receiveValue: { print($0); return false }, receiveCompletion: { print($0) }) //we will receive one value and then pause until next resume will be received

subject.send(1)
subject.send(2)
subject.send(3)
pausable.resume()
subject.send(4)
subject.send(5)
subject.send(6)
pausable.resume()
subject.send(7)
subject.send(8)
subject.send(9)
subject.send(completion: .finished)
pausable.resume()
