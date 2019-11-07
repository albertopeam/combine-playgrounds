import Foundation
import PlaygroundSupport
import Combine

struct API {
    /// API Errors.
    enum Error: LocalizedError {
        case addressUnreachable(URL)
        case invalidResponse

        var errorDescription: String? {
            switch self {
                case .invalidResponse: return "The server responded with garbage."
                case .addressUnreachable(let url): return "\(url.absoluteString) is unreachable."
            }
        }
    }

    /// API endpoints.
    enum EndPoint {
        static let baseURL = URL(string: "https://hacker-news.firebaseio.com/v0/")!

        case stories
        case story(Int)

        var url: URL {
            switch self {
                case .stories:
                    return EndPoint.baseURL.appendingPathComponent("newstories.json")
                case .story(let id):
                    return EndPoint.baseURL.appendingPathComponent("item/\(id).json")
            }
        }
    }

    /// Maximum number of stories to fetch (reduce for lower API strain during development).
    var maxStories = 10

    /// A shared JSON decoder to use in calls.
    private let decoder = JSONDecoder()
    private let apiQueue = DispatchQueue(label: "api", qos: .default, attributes: .concurrent)
  
    func stories() -> AnyPublisher<[Story], Error> {
         return URLSession.shared
            .dataTaskPublisher(for: EndPoint.stories.url)
            .receive(on: apiQueue)
            .map(\.data)
            .decode(type: [Int].self, decoder: decoder)
            .mapError({ (error) -> Error in
                switch error {
                case is URLError:
                    return Error.addressUnreachable(EndPoint.stories.url)
                default:
                    return Error.invalidResponse
                }
            })
            .filter({ !$0.isEmpty })
            .map({ $0.sorted() })
            .flatMap({ ids in self.mergedStories(ids: ids) })
            .scan([], { $0 + [$1] })
            .eraseToAnyPublisher()
    }
    
    func story(id: Int) -> AnyPublisher<Story, Error> {
        return URLSession.shared
            .dataTaskPublisher(for: EndPoint.story(id).url)
            .receive(on: apiQueue)
            .map(\.data)
            .decode(type: Story.self, decoder: decoder)
            .mapError({ (error) -> Error in
                switch error {
                case DecodingError.dataCorrupted:
                    return Error.invalidResponse
                default: return Error.addressUnreachable(EndPoint.story(id).url)
                }
            })
            .catch { _ in Empty<Story, Error>() }
            .eraseToAnyPublisher()
    }
    
    func mergedStories(ids storyIDs: [Int]) -> AnyPublisher<Story, Error> {
        precondition(!storyIDs.isEmpty)
        
        let storyIds = storyIDs.prefix(maxStories)
        let initialPublisher = story(id: storyIds.first!)
        let remainder = storyIds.dropFirst()
        
        return remainder.reduce(initialPublisher) { (combined, id) in
            combined
                .merge(with: story(id: id))
                .eraseToAnyPublisher()
        }
    }
}

var cancelables = [AnyCancellable]()
let api = API()
api.story(id: 1000)
    .receive(on: RunLoop.main)
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &cancelables)

api.mergedStories(ids: [1000, 1001, 1002])
    .collect()
    .receive(on: RunLoop.main)
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &cancelables)

api.stories()
    .receive(on: RunLoop.main)
    .sink(receiveCompletion: { print($0) }, receiveValue: { print($0) })
    .store(in: &cancelables)

// Run indefinitely.
PlaygroundPage.current.needsIndefiniteExecution = true

/// Copyright (c) 2019 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.
