import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()
let publisher = URLSession.shared
    .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.com")!)
    .map(\.data)
    .print("shared") // be carefull, if we use print after share it won´t act like a share because it will not assign a reference publisher, instead it will be value publisher. When someone subscribes it will start doing stuff, if anyone later do the same it will trigger all the stuff.
    .share() //it will share downstream all the data fetched by upstream only once, the bad side is that if we connect more than once and some subscriber after the upstream was finished, then we will only receive the completion event not the data.

publisher
    .sink(receiveCompletion: { _ in }, receiveValue: { print($0) })
    .store(in: &subscriptions)

publisher
    .sink(receiveCompletion: { _ in }, receiveValue: { print($0) })
    .store(in: &subscriptions)

DispatchQueue.main.schedule(after: .init(.now() + 2.5)) {
    publisher
        .sink(receiveCompletion: { print("3rd subscription \($0) because publisher has already emitted its data") }, receiveValue: { print($0) })
        .store(in: &subscriptions)
}


