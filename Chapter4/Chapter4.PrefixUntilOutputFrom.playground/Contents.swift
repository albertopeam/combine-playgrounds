import Combine

var suscriptions = Set<AnyCancellable>()

let isReady = PassthroughSubject<Void, Never>()
let taps = PassthroughSubject<Void, Never>()
taps.prefix(untilOutputFrom: isReady)
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &suscriptions)
    


taps.send(())
taps.send(())
taps.send(())
taps.send(())

isReady.send(())

taps.send(()) // once isReady is sent taps will complete and it won´t emit any more value
