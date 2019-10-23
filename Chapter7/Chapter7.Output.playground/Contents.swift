import Combine

var subscriptions = Set<AnyCancellable>()

let items = [1, 2, 3, 5, 7, 11, 13]
    
let publisher = items.publisher.share()

let at: Int = 2
items.publisher
    .print()
    .output(at: at) // The operator demands one more value after every emitted value, since it knows it's only looking for an item at a specific index
    .sink(receiveValue: { print("Output at \(at): \($0)") })
    .store(in: &subscriptions)

let range = 1...2
items.publisher
    .print()
    .output(in: range) // when using a range it will emit N items in N events, once the last in the range is emitted it will be canceled
    .collect() // using collect to avoid individual items sent to the sink
    .sink(receiveValue: { print("Output at range \(range): \($0)") })
    .store(in: &subscriptions)
