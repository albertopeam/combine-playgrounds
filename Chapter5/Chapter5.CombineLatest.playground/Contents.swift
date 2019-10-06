import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

let publisher1 = PassthroughSubject<Int, Never>()
let publisher2 = PassthroughSubject<String, Never>() // diff types of publishers

publisher1
    .combineLatest(publisher2)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

publisher1.send(0) // if we only send this one, it wont be triggered to the sink block because we need at least one event for both publishers to start publishing, once both emit the its first value whatever next value or values will be emitted. Take into consideration that the data can be repeated
publisher2.send("a") // (0, "a")

publisher1.send(1) // (1, "a")
publisher1.send(2) // (2, "a")

publisher1.send(completion: .finished)
publisher2.send(completion: .finished)

