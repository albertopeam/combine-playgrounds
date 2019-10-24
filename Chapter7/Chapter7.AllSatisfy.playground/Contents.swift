import Combine

let odd: (_ number: Int) -> Bool = { return $0 % 2 == 0 }
var subscriptions = Set<AnyCancellable>()
(0...9).publisher
    .print()
    .allSatisfy(odd)
    .sink { (odd) in
        print("All satisfy being odd: \(odd ? "true":"false")")
    }
    .store(in: &subscriptions)


[0, 2, 4, 8, -16].publisher
    .print()
    .allSatisfy(odd)
    .sink { (odd) in
        print("All satisfy being odd: \(odd ? "true":"false")")
    }
    .store(in: &subscriptions)
