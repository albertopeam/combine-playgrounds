import Combine

var subscriptions = Set<AnyCancellable>()

extension Int {
    func isMultiple(of value: Int) -> Bool {
        return self % value == 0
    }
}

(0...10).publisher
    .filter({ $0.isMultiple(of: 3)})
    .sink(receiveValue:{ print($0) })
    .store(in: &subscriptions)
