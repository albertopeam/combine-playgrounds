import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()
let queue = OperationQueue()

queue.publisher(for: \.operationCount) // KVO observing using publisher
    .print()
    .sink(receiveValue: { print($0) })
    .store(in: &subscriptions)

queue.addOperation {
    print("Added Op.")
}

// classic KVO property observing
class Stuff: NSObject {
    @objc dynamic var property: String
    
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
