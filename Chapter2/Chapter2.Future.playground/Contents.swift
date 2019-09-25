 import Foundation
 import Combine
 
 var subscriptions = Set<AnyCancellable>()
 
 func futureInc(base: Int, delay: TimeInterval) -> Future<Int, Never> {
    return .init { (promise) in
        print("Promise Go")
        // Promise executes as soon it is created
        DispatchQueue.global().asyncAfter(deadline: .now() + delay) {
          promise(.success(base + 1))
        }
    }
 }

 let future = futureInc(base: 0, delay: 1)
 future.sink(receiveCompletion: { (completion) in
    print("completion")
 }) { (value) in
    print("received: \(value)")
 }.store(in: &subscriptions)
 
 // This sink(subscription block) will share state with previous one
 future.sink(receiveCompletion: { (completion) in
    print("completion2")
 }) { (value) in
    print("received2: \(value)")
 }.store(in: &subscriptions)
 
 
