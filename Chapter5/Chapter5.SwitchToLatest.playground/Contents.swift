import Combine
import Foundation
import UIKit

var subscriptions = Set<AnyCancellable>()

let publisher1 = PassthroughSubject<Int, Never>()
let publisher2 = PassthroughSubject<Int, Never>()
let publisher3 = PassthroughSubject<Int, Never>()

let publishers = PassthroughSubject<PassthroughSubject<Int, Never>, Never>()
publishers
    .print()
    .switchToLatest()
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscriptions)

publishers.send(publisher1) // the last publisher sended to the publishers will be the source of data.
publisher1.send(1)
publisher1.send(2)

publishers.send(publisher2) // it will cancel the subscription to publisher1
publisher1.send(1) // it won´t be triggered because switchToLatest is getting values from publisher2
publisher2.send(3)
publisher2.send(4)

publishers.send(publisher3) // it will cancel the subscription to publisher2
publisher2.send(3) // it won´t be triggered because switchToLatest is getting values from publisher3
publisher3.send(5)
publisher3.send(6)

publisher3.send(completion: .finished) // not finished publishers, this only closes publisher 3 but not the publishers
publishers.send(completion: .finished)

print("")
print("")

var subscription: AnyCancellable?
let url = URL(string: "https://source.unsplash.com/random")!

func getImage() -> AnyPublisher<UIImage?, Never>{
    return URLSession.shared
        .dataTaskPublisher(for: url)
        .map({ data, _ in UIImage(data: data) })
        .print("image")
        .replaceError(with: nil)
        .eraseToAnyPublisher()
}

let taps = PassthroughSubject<Void, Never>()
subscription = taps
    .map({ _ in getImage() })   // map to publisher
    .switchToLatest()           // cancels previous subscriptions and only will emit events from one publisher
    .sink(receiveValue: { _ in })

taps.send()

DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
  taps.send()
}
DispatchQueue.main.asyncAfter(deadline: .now() + 3.1) {
  taps.send() // this one will cancel second tap
}
