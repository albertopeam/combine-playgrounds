import Combine

var subs = Set<AnyCancellable>()
["A", "B", "C"]
    .publisher
    .print()
    .first() // It won´t wait until the publisher finishes, because when the first element is emitted the publisher will completes
    .sink(receiveValue: { print("First: \($0)") })
    .store(in: &subs)

["J", "O", "H", "N"]
    .publisher
    .print()
    .first(where: { "sOme senteNce".contains($0) }) //when first returns true first time it will send the letter and finish
    .sink(receiveValue: { print("First Letter: \($0)") })
    .store(in: &subs)
