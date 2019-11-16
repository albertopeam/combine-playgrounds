import Combine

var subscriptions: Set<AnyCancellable> = .init()

enum MyError: Error {
    case ohNo
}

Just("Hello")
    .print("Just")
    .sink(receiveValue: { print($0) }) // error output is Never
    .store(in: &subscriptions)

Just(["1", "2", "a", "3"])
    .print("Just-parse")
    .flatMap({ $0.publisher })
    .tryMap({
        if let parsed = Int($0) {
            return parsed
        }
        throw MyError.ohNo // forcing error from a non throwing
    })
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0 )})
    .store(in: &subscriptions)

Just("Hello")
    .print("Just-setFailure")
    .setFailureType(to: MyError.self) // setting the output error, but it won´t trigger it
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0 )})
    .store(in: &subscriptions)
