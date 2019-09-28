import Combine

var subscrioptions = Set<AnyCancellable>()

[1,2,3].publisher
    .scan(0, { $0 + $1 }) // scan stores a value and then it can be applied in someway to the new sended value
    .sink(receiveValue: {print("output: \($0)") })
    .store(in: &subscrioptions)

