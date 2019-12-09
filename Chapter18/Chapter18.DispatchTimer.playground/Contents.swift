import Foundation
import Combine

struct DispatchTimerConfiguration {
    let queue: DispatchQueue?
    let interval: DispatchTimeInterval
    let leeway: DispatchTimeInterval
    let times: Subscribers.Demand
}

extension Publishers {
    static func timer(queue: DispatchQueue? = nil,
                      interval: DispatchTimeInterval,
                      leeway: DispatchTimeInterval = . nanoseconds(0),
                      times: Subscribers.Demand = .unlimited) -> DispatchTimer {
        let configuration = DispatchTimerConfiguration.init(queue: queue,
                                                            interval: interval,
                                                            leeway: leeway,
                                                            times: times)
        return Publishers.DispatchTimer(configuration: configuration)
    }

    struct DispatchTimer: Publisher {
        typealias Output = DispatchTime
        typealias Failure = Never

        let configuration : DispatchTimerConfiguration

        func receive<S>(subscriber: S) where S : Subscriber, Failure == S.Failure, Output == S.Input {
            print("DispatchTimer.Publisher receive subscription")
            let subscription = DispatchTimerSubscription(subscriber: subscriber, configuration: configuration)
            subscriber.receive(subscription: subscription)
        }
    }

    private final class DispatchTimerSubscription<S: Subscriber>: Subscription where S.Input == DispatchTime {
        var combineIdentifier: CombineIdentifier = .init()

        var subscriber: S?
        let configuration : DispatchTimerConfiguration
        var times: Subscribers.Demand // global max
        var requested: Subscribers.Demand = .none // local times
        var source: DispatchSourceTimer? = nil

        init(subscriber: S, configuration : DispatchTimerConfiguration) {
            self.subscriber = subscriber
            self.configuration = configuration
            self.times = configuration.times
        }

        func request(_ demand: Subscribers.Demand) { // if now backpressure control, demand is always unlimited. invoked only once because demand haven´t changed
            print("newDemand: \(demand.description)")
            guard times > .none else { // if any subscription arrives after sending the times values, then it will be feed with the .finished
                subscriber?.receive(completion: .finished)
                print("times have been exceeded!, breaking execution")
                return
            }
            requested += demand
            print("newRequested: \(requested.description)")
            if source == nil, requested > .none {
                let timer = DispatchSource.makeTimerSource(queue: configuration.queue)
                timer.schedule(deadline: .now() + configuration.interval,
                                 repeating: configuration.interval,
                                 leeway: configuration.leeway)
                timer.setEventHandler(handler: { [weak self] in
                    guard let self = self else { return }
                    guard self.requested > .none else {
                        print("request == none, breaking execution")
                        return
                    }

                    print("tick")

                    self.requested -= .max(1)
                    print("RequestedBlock: \(self.requested.description)")
                    self.times -= .max(1)
                    print("TimesBlock: \(self.times.description)")

                    self.subscriber?.receive(.now())
                    if self.times == .none {
                        print("timesBlock have been exceeded!, breaking execution")
                        self.subscriber?.receive(completion: .finished)
                    }
                })
                source = timer
                timer.activate()
                print("Activate")
            }
        }

        func cancel() {
            print("Cancel")
            source = nil
            subscriber = nil
        }
    }
}

let timer = Publishers.timer(interval: .seconds(1), times: .max(2))

// SINK SUBSCRIPTION
var subscriptions = Set<AnyCancellable>()
var logger = TimeLogger(sinceOrigin: true)
timer
    .sink(receiveValue: { print("Timer emits: \($0)", to: &logger) })
    .store(in: &subscriptions)

//CUSTOM SUBSCRIBER
class TimerSubscriber: Subscriber {
    typealias Input = DispatchTime
    typealias Failure = Never

    private var subscriptions = Set<AnyCancellable>()

    func receive(subscription: Subscription) {
        print("receive(subscription:)")
        subscription.request(.max(1)) // we only want one
        subscription.store(in: &subscriptions)
    }

    func receive(_ input: DispatchTime) -> Subscribers.Demand {
        print("receive(_ input:)")
        return .none
    }

    func receive(completion: Subscribers.Completion<Never>) {
        print("receive(completion:)")
    }
}

let subscriber = TimerSubscriber()
timer.subscribe(subscriber)
