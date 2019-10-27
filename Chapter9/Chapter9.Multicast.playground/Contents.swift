import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()
let publisher = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com/")!)
    .print()
    .map(\.data)
    .multicast({ PassthroughSubject<Data, URLError>() }) // it creates a connectable publisher, so it won´t start doing stuf until we proceed invoking connect. We could use share but we must be forced to connect all the sinks before the response is back, otherwise only some of them will listen the response

publisher
    .sink(receiveCompletion: { (completion) in
        if case .failure(let err) = completion {
          print("Sink1 Retrieving data failed with error \(err)")
        }
    }) { (data) in
        print("Sink1: \(data)")
    }.store(in: &subscriptions)

publisher
    .sink(receiveCompletion: { (completion) in
        if case .failure(let err) = completion {
          print("Sink2 Retrieving data failed with error \(err)")
        }
    }) { (data) in
        print("Sink2: \(data)")
    }.store(in: &subscriptions)

let subscription = publisher.connect()

