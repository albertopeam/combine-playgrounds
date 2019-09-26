import Combine
var subscriptions = Set<AnyCancellable>()
["hi", "my", "name", "is", "happy"]
    .publisher
    .collect() // groups the items
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

["hi", "my", "name", "is", "happy"]
    .publisher
    .collect(3) // groups the items in batches of `count`
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
