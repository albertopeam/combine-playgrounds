import Combine
import Foundation

// A subject you get values from
let subject = PassthroughSubject<Int, Never>()
let strings = subject
    .collect(.byTime(DispatchQueue.main, .seconds(0.5)))
    .map({ String($0.map({ val in Character(Unicode.Scalar(val)!) })) })

let measure = subject.measureInterval(using: RunLoop.main)
    .map({ $0.magnitude > 0.9 ? "👏" : "" })

var subscriptions = Set<AnyCancellable>()
strings
    .merge(with: measure)
    .filter({ !$0.isEmpty })
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

// Let's roll!
startFeeding(subject: subject)
