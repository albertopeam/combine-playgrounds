import Combine

var subscriptions = Set<AnyCancellable>()
let subject = PassthroughSubject<Coordinate, Never>()
subject.map(\.x, \.y) // it is like a decomposing to for example not reveal the type
    .sink(receiveValue: { print("x: \($0), y: \($1), quadrant: \(quadrantOf(x: $0, y: $1))")})
    .store(in: &subscriptions)

subject.send(.init(x: 0, y: 0))
subject.send(.init(x: 1, y: 1))
