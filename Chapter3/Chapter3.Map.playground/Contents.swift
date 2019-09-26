import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

let formatter: NumberFormatter = .init()
formatter.numberStyle = .spellOut

enum FormatError: Error {
    case spellOut
}

[25, 101, -1].publisher
    .tryMap({
        if let formatted = formatter.string(from: NSNumber(integerLiteral: $0)) {
            return formatted
        } else {
            throw FormatError.spellOut //we can throw to handle the error in the completion block
        }
    })
    .replaceError(with: "")
    .sink(receiveCompletion: { (completion) in
        print(completion)
    }, receiveValue: { (output) in
        print(output)
    })
    .store(in: &subscriptions)
 
print("")

[1, 13, 32].publisher
    .map({ formatter.string(from: .init(integerLiteral: $0)) ?? "" }) //send an empty to avoid handling error
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
