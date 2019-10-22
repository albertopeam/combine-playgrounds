import Combine

var subs = Set<AnyCancellable>()
["A", "B", "C", "D"]
    .publisher
    .print()
    .last() // last will wait until the publisher emits finish to be able to determine what was the last value
    .sink(receiveValue: { print("Last: \($0)") })
    .store(in: &subs)


"Hi, my name is a common name like others"
    .split(separator: " ")
    .publisher
    .print()
    .last(where: { $0 == "name"})
    .sink(receiveValue: { print("Last: \($0)") })
    .store(in: &subs)
