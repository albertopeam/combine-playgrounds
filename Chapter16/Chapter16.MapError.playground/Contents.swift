import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

enum NameError: Error {
    case tooShort(String)
    case unknown
}

Just("Hello")
    .print()
    .setFailureType(to: NameError.self)
    .tryMap { throw NameError.tooShort($0) } // force error to show mapError in action
    //.tryMap { $0 + " World!" } // tryMap erases NameError to Swift.Error
    .mapError({ $0 as? NameError ?? .unknown }) // so we need to map to the expected error in sink block
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished: break
        case let .failure(error):
            switch error {
            case .tooShort(_):
               print("tooShort")
            case .unknown:
               print("unknown")
            }
        }
    }, receiveValue: { print($0)  })
    .store(in: &subscriptions)
