import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()
// classic KVO property observing
class Stuff: NSObject {
    @objc dynamic var property: String //KVO observing will work with any Swift type that is bridget to Obj-C type. This mean any Swift native type, we can not try to make KVO of custom structs
    
    init(property: String) {
        self.property = property
    }
}

let someStuff = Stuff(property: "!")
someStuff.property = "Hello!"
someStuff
    .publisher(for: \.property)
    .print()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)
someStuff.property = "Hello World!"
