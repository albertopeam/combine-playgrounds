import Combine
import Foundation

class Counter: NSObject {
    @objc dynamic var count: Int
    
    init(count: Int) {
        self.count = count
    }
}

var subscriptions = Set<AnyCancellable>()
Counter(count: 0)
    .publisher(for: \.count, options: []) // empty means doesn´t send initial value
    .print("[]")
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

let initial = Counter(count: 0)
initial
    .publisher(for: \.count, options: [.initial]) // sends initial and later events
    .print("initial")
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
initial.count += 1

let prior = Counter(count: 0)
prior
    .publisher(for: \.count, options: [.prior]) // when something changes in the count it sends two events with the previous and the new value. at least needed two values to start sending values to sink
    .print("prior")
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
prior.count += 1
prior.count += 1

let priorCollect = Counter(count: 0)
priorCollect
    .publisher(for: \.count, options: [.prior]) // when something changes in the count it sends two events with the previous and the new value. at least needed two values to start sending values to sink
    .print("prior+collect")
    .collect(2)
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
priorCollect.count += 1
priorCollect.count += 1
priorCollect.count += 1
priorCollect.count += 1

let priorNotEnoughValues = Counter(count: 0)
priorNotEnoughValues
    .publisher(for: \.count, options: [.prior]) //  at least needed two values to start sending values to sink, if only initial it won´t emit any
    .print("priorNotEnoughValues")
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

let old = Counter(count: 0)
old
    .publisher(for: \.count, options: [.initial, .old]) //let the new value through. initial force to be sent
    .print("old")
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
old.count += 1
old.count += 1
old.count += 1
old.count += 1

let new = Counter(count: 0)
new
    .publisher(for: \.count, options: [.new]) // let the new value through. initial avoided to be sent because we have´t included it
    .print("new")
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
new.count += 1
new.count += 1
new.count += 1
new.count += 1
