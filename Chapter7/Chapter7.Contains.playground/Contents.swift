import Combine

var subscriptions = Set<AnyCancellable>()
let items = ["A", "B", "C", "D", "E"]

let item = "D"
items.publisher
    .print()
    .contains(item) // contains is lazy, only need to find the element, once finded it will cancel the subscription. if the publisher emits all its values and none of them is the expected it will finish with a false value
    .sink(receiveValue: { print("is contained? \($0)")})
    .store(in: &subscriptions)

// finding a value that is not comparable

struct Person {
    let id: Int
    let name: String
}
let people = [
    (456, "Scott Gardner"),
    (123, "Shai Mishali"),
    (777, "Marin Todorov"),
    (214, "Florent Pillet")
]
people
    .map({ Person(id: $0, name: $1)})
    .publisher
    .print()
    .contains(where: { $0.id == 1 || $0.name == "Marin Todorov" })
    .sink(receiveValue: { print($0 ? "Criteria matches!" : "Couldn't find a match for the criteria") })
    .store(in: &subscriptions)

// with an anonymous function

let function: (_ person: Person) -> Bool = { (person) in
    return person.id == 215 || person.name == "Mar Todorov"
}
people
    .map({ Person(id: $0, name: $1)})
    .publisher
    .print()
    .contains(where: function)
    .sink(receiveValue: { print($0 ? "Criteria matches!" : "Couldn't find a match for the criteria") })
    .store(in: &subscriptions)
