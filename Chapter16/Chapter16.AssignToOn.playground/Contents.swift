import Combine

var subscriptions = Set<AnyCancellable>()

class SomeData {
    var stuff: String = "" {
        didSet {
            print(stuff)
        }
    }
}
var data: SomeData = .init()

Just("Name")
    .assign(to: \.stuff, on: data) // only work on types that matches Never as Failure. Keypath style
    .store(in: &subscriptions)
