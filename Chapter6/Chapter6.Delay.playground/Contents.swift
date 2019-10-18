import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()
Just("Hello")
    .print()
    .delay(for: .seconds(1), scheduler: DispatchQueue.main)
    .sink(receiveValue: { print($0)})
    .store(in: &subscriptions)
