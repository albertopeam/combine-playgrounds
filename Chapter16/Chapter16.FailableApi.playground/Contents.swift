import Combine
import Foundation

class DadJokes {
    enum Error: Swift.Error, CustomStringConvertible {
        case network
        case jokeDoesntExist(id: String)
        case parsing
        case unknown
        var description: String {
            switch self {
            case .network:
                return "Request to API Server failed"
            case .parsing:
                return "Failed parsing response from server"
            case .jokeDoesntExist(let id):
                return "Joke with ID \(id) doesn't exist"
            case .unknown:
                return "An unknown error occurred"
            }
        }
    }
    struct Joke: Codable {
        let id: String
        let joke: String
    }

    func getJoke(id: String) -> AnyPublisher<Joke, Error> {
        guard id.rangeOfCharacter(from: .letters) != nil else {
            return Fail<Joke, Error>(error: .jokeDoesntExist(id: id))
                .eraseToAnyPublisher()
        }
        let url = URL(string: "https://icanhazdadjoke.com/j/\(id)")!
        var request = URLRequest(url: url)
        request.allHTTPHeaderFields = ["Accept": "application/json"]
        return URLSession.shared.dataTaskPublisher(for: request)
            .print()
            .tryMap { data, _ -> Data in
                guard let obj = try? JSONSerialization.jsonObject(with: data),
                    let dict = obj as? [String: Any],
                    dict["status"] as? Int == 404 else {
                        return data
                }
                throw DadJokes.Error.jokeDoesntExist(id: id)
            }
            .decode(type: Joke.self, decoder: JSONDecoder())
            .mapError({ (error) -> Error in
                switch error {
                case is URLError:
                    return .network
                case is DecodingError:
                    return .parsing
                default:
                    return error as? DadJokes.Error ?? .unknown
                }
            })
            .eraseToAnyPublisher()
    }
}

let jokeID = "9prWnjyImyd"
let anotherJokeId = "tkji39992Ed"
let badJokeID = "123456"
var subscriptions: Set<AnyCancellable> = .init()

let api = DadJokes()
[jokeID, anotherJokeId]
    .publisher
    .print()
    .setFailureType(to: DadJokes.Error.self)
    .flatMap({ api.getJoke(id: $0) })
    .collect()
    .sink(receiveCompletion: { (completion) in
        switch completion {
            case .finished: print("finished")
            case let .failure(error): print(error)
        }
    }) { (jokes) in
        print(jokes)
    }.store(in: &subscriptions)
