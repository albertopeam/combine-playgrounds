import Combine

var subscriptions = Set<AnyCancellable>()
["H","e","l","l","o","!"].publisher
    .print()
    .reduce("", +) // when it receives the finishes it will publish downstream the final value
    .sink(receiveValue: {print($0)})
    .store(in: &subscriptions)

["H","e","l","l","o","!"].publisher
    .print()
    .scan("", +) // the diff between scan and reduce is that scan emits every combination of accumulated seed + event, reduce only one final event
    .sink(receiveValue: {print($0)})
    .store(in: &subscriptions)
