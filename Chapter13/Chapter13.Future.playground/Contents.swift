import Combine
import Foundation

var subscriptions = Set<AnyCancellable>()

let publisher: AnyPublisher<Data, Error> = Future<Data, Error> { (promise) in
    print("future starts")
    // future starts inmediatly
    URLSession.shared.dataTask(with: URL(string: "https://google.es")!) { (data, response, error) in
        if let data = data {
            promise(.success(data))
        } else if let error = error {
            promise(.failure(error))
        }
        
    }.resume()
}
.print("future")
.eraseToAnyPublisher()
// sharing a future means that the response of its result will be sended to any subscriber subscribed before or after the future finish

publisher
    .sink(receiveCompletion: { _ in }, receiveValue: { print("subscriber1: \($0)")})
    .store(in: &subscriptions)

DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
    publisher
        .sink(receiveCompletion: { _ in }, receiveValue: { print("subscriber2: \($0)")})
        .store(in: &subscriptions)

}
