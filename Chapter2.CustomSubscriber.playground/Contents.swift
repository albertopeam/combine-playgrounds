import Combine

class IntSubscriber: Subscriber {
    typealias Input = Int
    typealias Failure = Never
    
    private let demand: Subscribers.Demand
    
    init(demand: Subscribers.Demand) {
        self.demand = demand
    }
    
    func receive(subscription: Subscription) {
        subscription.request(.max(3)) //max items to receive initially(backpressure)
        // request param Subscribers.Demand:
            // .none //no admit more items
            // .unlimited //admit unlimited
    }
    
    func receive(_ input: Int) -> Subscribers.Demand {
        print("receive: \(input)")
        return demand //max items to append to receive for next(adds to the initial one)
    }
    
    func receive(completion: Subscribers.Completion<Never>) {
        print("completed", completion)
    }
}

let publisher = [0, 1, 1, 2, 3, 5, 8].publisher
publisher.subscribe(IntSubscriber(demand: .unlimited))

let threeValuesPublisher = [0, 1, 1, 2, 3, 5, 8].publisher
threeValuesPublisher.subscribe(IntSubscriber(demand: .none)) //never finishes(func receive(completion: Subscribers.Completion<Never>)) because it has more values than it could publish due to the injected demand
