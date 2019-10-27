import Combine

class Person {
    @Published var age: Int = 0 // @Published creates a property called $age that is a Publisher. It never fails
    init(age: Int) {
        self.age = age
    }
}

var subscriptions = Set<AnyCancellable>()
var someone: Person = .init(age: 1)
someone.$age
    .eraseToAnyPublisher()
    .sink(receiveValue: { print("Age: \($0)") })
    .store(in: &subscriptions)

someone.age = 16
