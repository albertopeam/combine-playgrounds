import Combine

var subs = Set<AnyCancellable>()
["A", "F", "Z", "E"]
    .publisher
    .print()
    .max() // String is Comparable so we can use shoarthand version of max. Publisher must finish before max can be computed
    .sink(receiveValue: { print("Max: \($0)") })
    .store(in: &subs)
