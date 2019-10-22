import Foundation
import Combine

var subscriptions = Set<AnyCancellable>()
let array = [-1, 50, 246, 0]
array.publisher
    .print()
    .min() //min will only be computed when the publisher emits the .finished event
    .sink(receiveValue: { print("Min: \($0)") })
    .store(in: &subscriptions)

array.publisher
    .print()
    .min(by: { abs($0) < abs($1) })
    .sink(receiveValue: { print("Abs min: \($0)") })
    .store(in: &subscriptions)

let publisher = ["12345", "ab", "hello world"]
    .compactMap { $0.data(using: .utf8) }
    .publisher

let data: Data = .init()
publisher
    .print()
    .min(by: { $0.count < $1.count }) //Data is not Comparable so we don´t have min() version, we must provide one
    .sink(receiveValue: {
        let string = String(data: $0, encoding: .utf8)!
        print("Smallest data is \(string), \($0.count) bytes")
    }).store(in: &subscriptions)
