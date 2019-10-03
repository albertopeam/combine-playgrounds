import Combine

var suscriptions = Set<AnyCancellable>()

[3, 4, 5].publisher
    .append(6, 7)
    .append([8, 9])
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &suscriptions)

print("")

let subject = PassthroughSubject<Int, Never>()
subject.append([3, 4, 5].publisher)
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &suscriptions)

subject.send(1)
subject.send(2)
subject.send(completion: .finished) // it needs to be completed before start emiting appended elements otherwise the append would be inconsistent

print("")

let publisher1 = [1, 2].publisher
let publisher2 = [3, 4].publisher

publisher1.append(publisher2)
    .sink(receiveValue: { print($0) })
    .store(in: &suscriptions)
