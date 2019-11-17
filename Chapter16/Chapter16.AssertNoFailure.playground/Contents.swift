import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

let error = NSError(domain: "", code: 0, userInfo: nil)

Just("Hello")
    .print("AssertNoFailure")
    .setFailureType(to: Error.self)
    .assertNoFailure() //raises a fatal error if upstream sends a Error. Also ensures that the publisher becomes non Failable => Failure = Never
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

Fail(outputType: String.self, failure: NSError(domain: "", code: 0, userInfo: nil))
    .print("Fail")
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &subscriptions)

Just("Hello")
    .print("Crash-Just")
    .setFailureType(to: Error.self)
    .tryMap({ _ in throw error })
    .assertNoFailure()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

Fail(outputType: String.self, failure: error)
    .print("Crash-Fail")
    .assertNoFailure() // it will crash
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
