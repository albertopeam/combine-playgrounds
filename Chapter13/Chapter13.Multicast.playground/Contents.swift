import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()
let subject = PassthroughSubject<Data, URLError>()
let multicast = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
    .map(\.data)
    .print("multicast")
    .multicast(subject: subject)

subject
    .print("not delayed")
    .sink(receiveCompletion: { _ in }, receiveValue: { print($0) })
    .store(in: &subscriptions)

DispatchQueue.main.schedule(after: .init(.now() + 2.5)) {
    subject
        .print("delayed")
        .sink(receiveCompletion: { _ in }, receiveValue: { print($0) })
        .store(in: &subscriptions)
    
    multicast.connect() // we need to connect before sending events, after this all subscribers will see all the data
    subject.send(Data()) // it doesn´t start to fetch network data..., so we fake it.
}

