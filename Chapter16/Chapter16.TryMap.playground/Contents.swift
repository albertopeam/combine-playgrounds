import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

enum NameError: Error {
    case tooShort(String)
    case unknown
}

let names: [String] = ["Albert", "Isaac", "Maxwell"]
names.publisher
    .print()
    .tryMap({ (name) -> Int in // tryMap converts the non throwing publisher into a throwing one
        if name.count <= 5 {
            throw NameError.tooShort(name)
        }
        return name.count
    })
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0)  })
    .store(in: &subscriptions)
