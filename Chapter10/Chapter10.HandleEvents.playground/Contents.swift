import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()
URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com/")!)
    .receive(on: RunLoop.main)
    .handleEvents(receiveSubscription: { _ in // makes side effects changes not related to downstream, it is executed in main inclusive without the receive(on:), it also can be used to intercept lifecycle events
        print("Network request will start")
    }, receiveOutput: { _ in
        print("Network request data received")
    }, receiveCancel: {
        print("Network request cancelled")
    })
    .sink(receiveCompletion: { completion in
        print("Sink received completion: \(completion)")
    }) { (data, _) in
        print("Sink received data: \(data)")
    }.store(in: &subscriptions)
