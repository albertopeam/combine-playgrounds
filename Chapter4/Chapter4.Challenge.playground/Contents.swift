import Combine

var suscriptions = Set<AnyCancellable>()
(1...100).publisher
    .dropFirst(50)
    .prefix(20)
    .filter({ $0 % 2 == 0})
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &suscriptions)
    
