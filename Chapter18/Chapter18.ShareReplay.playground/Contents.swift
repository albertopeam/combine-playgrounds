import Combine
import Foundation

private final class ShareReplaySubscription<Output, Failure: Error>: Subscription {
    let capacity: Int
    var subscriber: AnySubscriber<Output, Failure>? = nil
    var demand: Subscribers.Demand = .none
    var buffer: [Output]
    var completion: Subscribers.Completion<Failure>? = nil // Stores upstream completion event if emitted

    init<S>(subscriber: S,
            replay: [Output],
            capacity: Int,
            completion: Subscribers.Completion<Failure>?) where S: Subscriber, Failure == S.Failure, Output == S.Input {
        self.subscriber = AnySubscriber(subscriber)
        self.buffer = replay
        self.capacity = capacity
        self.completion = completion
    }

    func request(_ demand: Subscribers.Demand) {
        if demand != .none {
            self.demand += demand
        }
        emitAsNeeded()
    }

    func cancel() {
        complete(with: .finished)
    }

    func receive(_ input: Output) {
        guard subscriber != nil else { return }
        buffer.append(input)
        if buffer.count > capacity {
            buffer.removeFirst()
        }
        emitAsNeeded()
    }

    func receive(completion: Subscribers.Completion<Failure>) {
        guard let subscriber = subscriber else { return }
        self.subscriber = nil
        self.buffer.removeAll()
        subscriber.receive(completion: completion)
    }

    private func complete(with completion: Subscribers.Completion<Failure>) {
        guard let subscriber = subscriber else { return }
        self.subscriber = nil
        self.completion = nil
        self.buffer.removeAll()
        subscriber.receive(completion: completion)
    }

    private func emitAsNeeded() {
        guard let subscriber = subscriber else { return } // if there is a subscriber
        while self.demand > .none && !buffer.isEmpty { // send if some demand and we have buffered data
            self.demand -= .max(1) // decrment demand before send
            let nextDemand = subscriber.receive(buffer.removeFirst()) // send a ask for a new demand
            if nextDemand != .none {
                self.demand += nextDemand // aument new demand
            }
        }
        if let completion = completion {
            complete(with: completion)
        }
    }
}

extension Publishers {
    final class ShareReplay<Upstream: Publisher>: Publisher {
        typealias Output = Upstream.Output
        typealias Failure = Upstream.Failure

        private let lock = NSRecursiveLock()
        private let upstream: Upstream
        private let capacity: Int
        private var replay = [Output]()
        private var subscriptions = [ShareReplaySubscription<Output, Failure>]()
        private var completion: Subscribers.Completion<Failure>? = nil

        init(upstream: Upstream, capacity: Int) {
            self.upstream = upstream
            self.capacity = capacity
        }

        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            lock.lock()
            defer { lock.unlock() }
            let subscription = ShareReplaySubscription(subscriber: subscriber, replay: replay, capacity: capacity, completion: completion)
            subscriptions.append(subscription)
            subscriber.receive(subscription: subscription)

            guard subscriptions.count == 1 else { return }
            let sink = AnySubscriber<Output, Failure>(receiveSubscription: { (subscription) in
                subscription.request(.unlimited)
            }, receiveValue: { [weak self] (value) -> Subscribers.Demand in
                self?.relay(value)
                return .none
            }) { [weak self] (completion) in
                self?.complete(completion)
            }
            upstream.subscribe(sink)
        }

        private func relay(_ value: Output) {
            lock.lock()
            defer { lock.unlock() }

            guard completion == nil else { return }

            replay.append(value)
            if replay.count > capacity {
                replay.removeFirst()
            }
            subscriptions.forEach({ $0.receive(value) })
        }

        private func complete(_ completion: Subscribers.Completion<Failure>) {
            lock.lock()
            defer { lock.unlock() }

            self.completion = completion
            subscriptions.forEach { $0.receive(completion: completion) }
        }
  }
}

extension Publisher {
    func replay(capacity: Int = .max) -> Publishers.ShareReplay<Self> {
        return Publishers.ShareReplay(upstream: self, capacity: capacity)
    }
}




let capacity = 2
let subject = CurrentValueSubject<Int, Never>(0) // for some reason this is sended.. if we use a CurrentValueSubject
let publisher = subject
    .print("REPLAY") // check that the publisher subscription is once
    .replay(capacity: capacity)
//subject.send(1) // Send an initial value through the subject. No subscriber has connected to the shared publisher, so you shouldn’t see any output.

var subscriptions = Set<AnyCancellable>()

// it will receive subject emitted values after subscription, emitted before won´t be send
publisher
    .sink(receiveCompletion: { print("1.replayCompleted: \($0)") },
          receiveValue: { print("1.replay \($0)") })
    .store(in: &subscriptions)

subject.send(2)
subject.send(3)
subject.send(4)
subject.send(completion: .finished)

// it will receive last capacity values and next ones
publisher
    .sink(receiveCompletion: { print("2.replayCompleted: \($0)") },
          receiveValue: { print("2.replay \($0)") })
    .store(in: &subscriptions)

// it will receive last capacity values and finish
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    print("Subscribing to replay after upstream completed")
    publisher
        .sink(receiveCompletion: { print("3.replayDelayedCompleted: \($0)") },
              receiveValue: { print("3.replayDelayed \($0)") })
        .store(in: &subscriptions)
}
