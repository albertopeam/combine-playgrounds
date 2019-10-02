import Combine

var subscriptions = Set<AnyCancellable>()

let isReady = PassthroughSubject<Void, Never>()
let taps = PassthroughSubject<Int, Never>()

taps
    .drop(untilOutputFrom: isReady)
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscriptions)

taps.send(1)
taps.send(2)
taps.send(3)    // it will be skiped while isReady not publishes something

isReady.send(())

taps.send(4)
taps.send(5)
