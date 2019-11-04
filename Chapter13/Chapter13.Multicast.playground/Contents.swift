import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

let multicast = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
    .map(\.data)
    .print("multicast")
    .multicast(subject: PassthroughSubject<Data, URLError>())
    // .autoconnect() this way it will be autoconnected, but we assume the risk that the task will be ended before all the subscribers are subscribed, then some of them won´t receive data never

multicast
    .sink(receiveCompletion: { _ in }, receiveValue: { print("subscriber1: \($0)") })
    .store(in: &subscriptions)

DispatchQueue.main.schedule(after: .init(.now() + 1)) {
    multicast
        .sink(receiveCompletion: { _ in }, receiveValue: { print("subscriber2: \($0)") })
        .store(in: &subscriptions)
}

var cancelable: Cancellable?
DispatchQueue.main.schedule(after: .init(.now() + 2.5)) {
    cancelable = multicast.connect() // if we want to be able to ensure that all our subscribers receive the same data, we must to connect after all the subscribers are done with the subscription
}



