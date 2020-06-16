import UIKit
import Combine
import PlaygroundSupport

// MARK: - snackbar
class SnackBar: UIView {

    private let view: UIView = .init(frame: .zero)
    private let label: UILabel = .init(frame: .zero)
    private let button: UIButton = .init(frame: .zero)

    override init(frame: CGRect) {
        super.init(frame: frame)
        view.translatesAutoresizingMaskIntoConstraints = false
        label.translatesAutoresizingMaskIntoConstraints = false
        button.translatesAutoresizingMaskIntoConstraints = false
        alpha = 0
        view.layer.cornerRadius = 8
        view.backgroundColor = UIColor(red: 0.50, green: 0.50, blue: 0.50, alpha: 1)
        label.numberOfLines = 1
        label.textColor = .white

        button.addTarget(self, action: #selector(click), for: .touchUpInside)

        addSubview(view)
        view.addSubview(label)
        view.addSubview(button)

        NSLayoutConstraint.activate([
            heightAnchor.constraint(equalToConstant: 64),
            view.topAnchor.constraint(equalTo: topAnchor),
            view.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            view.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            view.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),

            label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            button.leadingAnchor.constraint(equalTo: label.trailingAnchor, constant: 16),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            button.centerYAnchor.constraint(equalTo: view.centerYAnchor),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func show(message: String, action: String? = nil, publisher: AnyPublisher<Void, Never>? = nil) {
        //TODO: pending to create a publisher
        label.text = message
        button.setTitle(action, for: .selected)
        button.setTitle(action, for: .normal)
        UIView.animate(withDuration: 0.25, animations: {
            self.alpha = 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 6, execute: {
                UIView.animate(withDuration: 0.25, animations: {
                    self.label.text = nil
                    self.button.titleLabel?.text = nil
                    self.alpha = 0
                })
            })
        })
    }
}

// MARK: - view
class ViewController: UIViewController, Subscriber {
    typealias Input = ViewState
    typealias Failure = Never

    let spinner: UIActivityIndicatorView = .init(frame: .zero)
    let tableView: UITableView = .init(frame: .zero)
    let snackBar: SnackBar = .init(frame: .zero)
    let dataSource: SongsDataSource = .init()
    var lifecycle: CurrentValueSubject<Void, Never> = .init(())

    init() {
        super.init(nibName: nil, bundle: nil)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        tableView.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .gray
        spinner.hidesWhenStopped = true
        tableView.dataSource = dataSource
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 44
        snackBar.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(spinner)
        view.addSubview(tableView)
        view.addSubview(snackBar)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor),

            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            snackBar.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            snackBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            snackBar.trailingAnchor.constraint(equalTo: view.trailingAnchor)

        ])

        spinner.startAnimating()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    func receive(_ input: ViewState) -> Subscribers.Demand {
        input.isLoading ? spinner.startAnimating() : spinner.stopAnimating()
        dataSource.songs = input.songs
        tableView.reloadData()
        if let error = input.error {
            snackBar.show(message: error, action: input.retry)
        }
        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Never>) {}
}

// MARK: - datasource
class SongsDataSource: NSObject, UITableViewDataSource {
    var songs: [Song]

    init(songs: [Song] = .init()) {
        self.songs = songs
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return songs.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = songs[indexPath.row].title
        cell.textLabel?.textColor = .black
        return cell
    }
}

// MARK: - states
protocol ViewState {
    var isLoading: Bool { get }
    var songs: [Song] { get }
    var error: String? { get }
    var retry: String { get }
}

extension ViewState {
    var retry: String { "Retry" }
}

struct LoadingViewState: ViewState {
    let isLoading: Bool = true
    let songs: [Song] = .init()
    let error: String? = nil
}

struct ErrorViewSate: ViewState {
    let isLoading: Bool = false
    let songs: [Song] = .init()
    let error: String?
}

struct SuccessViewState: ViewState {
    let isLoading: Bool = false
    let songs: [Song]
    let error: String? = nil
}

// MARK: - view model
class ViewModel: Subscriber {
    typealias Input = Void
    typealias Failure = Never

    // MARK: - public
    @Published var state: ViewState
    // MARK: - private
    private let favourites: Favourites
    private var subscriptions: Set<AnyCancellable> = .init()

    init(state: ViewState = LoadingViewState(), favourites: Favourites = FavouritesRepository()) {
        self.state = state
        self.favourites = favourites
    }

    func receive(subscription: Subscription) {
        subscription.request(.max(1))
    }

    func receive(_ input: Void) -> Subscribers.Demand {
        favourites
            .songs()
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { [weak self] in
                switch $0 {
                case .finished:
                    break
                case .failure(_):
                    self?.state = ErrorViewSate(error: "Something went wrong")
                }
            }, receiveValue: { [weak self] in self?.state = SuccessViewState(songs: $0) })
            .store(in: &subscriptions)
        return .none
    }

    func receive(completion: Subscribers.Completion<Never>) {}
}

// MARK: - model
struct Song {
    let title: String
    let band: String
    let genre: String
    let url: URL
}

enum SongsError: Swift.Error {
    case notAvailable
}

// MARK: repository
protocol Favourites {
    func songs() -> AnyPublisher<[Song], SongsError>
}

class FavouritesRepository: Favourites {
    private let favouritesUrl = "https://raw.githubusercontent.com/albertopeam/combine-playgrounds/master/Freestyle/View_ViewModel.playground/Resources/songs.json"
    private let urlSession: URLSession
    private struct SongCodable: Codable {
        let band: String
        let song: String
        let genre: String
        let link: String
    }

    init(urlSession: URLSession = URLSession.shared) {
        self.urlSession = urlSession
    }

    func songs() -> AnyPublisher<[Song], SongsError> {
        guard let url = URL(string: favouritesUrl) else { fatalError("URL cannot be built") }
        return urlSession
            .dataTaskPublisher(for: url)
            .print("networking")
            .map(\.data)
            .decode(type: [SongCodable].self, decoder: JSONDecoder())
            .map({ songs in
                songs.compactMap({ song in
                    guard let url = URL(string: song.link) else { return nil }
                    return Song(title: song.song,
                                band: song.band,
                                genre: song.genre,
                                url: url)
                })
            }).mapError({ _ in
                return .notAvailable
            })
            .eraseToAnyPublisher()
    }
}

// MARK: - assembling
let view = ViewController()
let viewModel = ViewModel()
//_ = viewModel.$state.print("ViewState").sink(receiveValue: {_ in })
//_ = view.lifecycle.print("ViewLifecycle").sink(receiveValue: {_ in })
viewModel.$state.subscribe(view)
view.lifecycle.subscribe(viewModel)

// MARK: - playground
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view
