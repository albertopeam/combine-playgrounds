//
//  ViewController.swift
//  Chapter14.Challenge
//
//  Created by Alberto Penas Amor on 07/11/2019.
//  Copyright © 2019 com.github.albertopeam. All rights reserved.
//

import Foundation
import Combine
import UIKit

class StoriesViewController: UIViewController, UITableViewDataSource {

    private var cancelables = [AnyCancellable]()
    private let tableView = UITableView(frame: .zero, style: .plain)
    private let api = API()
    private var stories: [Story] = .init()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(StoryTableViewCell.self, forCellReuseIdentifier: String(describing: StoryTableViewCell.self))
        view.addSubview(tableView)
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        api.stories()
            .print()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { _ in },
                  receiveValue: { self.stories = $0; self.tableView.reloadData() })
            .store(in: &cancelables)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let id = String(describing: StoryTableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: id) as! StoryTableViewCell
        let story = stories[indexPath.row]
        cell.titleLabel.text = story.title
        cell.userLabel.text = story.by
        return cell
    }
}

class StoryTableViewCell: UITableViewCell {
    let titleLabel = UILabel(frame: .zero)
    let userLabel = UILabel(frame: .zero)
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: String(describing: StoryTableViewCell.self))
        titleLabel.textColor = .lightGray
        titleLabel.font = .systemFont(ofSize: 16)
        titleLabel.numberOfLines = 2
        userLabel.numberOfLines = 1
        userLabel.font = .systemFont(ofSize: 12)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        userLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(titleLabel)
        contentView.addSubview(userLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),

            userLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 10),
            userLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            userLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            userLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        userLabel.text = nil
    }
}

public struct Story: Codable {
  public let id: Int
  public let title: String
  public let by: String
  public let time: TimeInterval
  public let url: String
}

extension Story: Comparable {
    public static func < (lhs: Story, rhs: Story) -> Bool {
        return lhs.time > rhs.time
    }
}

extension Story: CustomDebugStringConvertible {
    public var debugDescription: String {
        return "\n\(title)\nby \(by)\n\(url)\n-----"
    }
}

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
