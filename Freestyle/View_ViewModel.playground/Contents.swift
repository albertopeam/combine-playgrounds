import UIKit
import Combine
import PlaygroundSupport

// MARK: - view
class View: UIView, Subscriber {
    typealias Input = ViewState
    typealias Failure = Never

    private let spinner: UIActivityIndicatorView = .init(frame: .zero)
    var lifecycle: CurrentValueSubject<Void, Never> = .init(())

    override init(frame: CGRect) {
        super.init(frame: frame)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.color = .gray

        addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        spinner.startAnimating()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func receive(subscription: Subscription) {
        subscription.request(.unlimited)
    }

    func receive(_ input: ViewState) -> Subscribers.Demand {
        input.isLoading ? spinner.startAnimating() : spinner.stopAnimating()
        return .unlimited
    }

    func receive(completion: Subscribers.Completion<Never>) {
        //TODO: needed something
    }
}

// MARK: - states
protocol ViewState {
    var isLoading: Bool { get }
}

struct LoadingViewState: ViewState {
    let isLoading: Bool = true
}

struct ErrorViewSate: ViewState {
    let isLoading: Bool = false
}

struct SuccessViewState: ViewState {
    let isLoading: Bool = false
}

// MARK: - view model
class ViewModel: Subscriber {
    typealias Input = Void
    typealias Failure = Never

    @Published var state: ViewState

    init(state: ViewState = LoadingViewState()) {
        self.state = state
    }

    func receive(subscription: Subscription) {
        subscription.request(.max(1))
    }

    func receive(_ input: Void) -> Subscribers.Demand {
        //TODO: doStuff
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.5, execute: {
            self.state = SuccessViewState()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
            self.state = LoadingViewState()
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 7.5, execute: {
            self.state = SuccessViewState()
        })
        return .none
    }

    func receive(completion: Subscribers.Completion<Never>) {
        //TODO: needed something
    }
}

// MARK: - assembling
let view = View(frame: .init(origin: .zero, size: .init(width: 320, height: 480)))
let viewModel = ViewModel()
//_ = viewModel.$state.print("ViewState").sink(receiveValue: {_ in })
//_ = view.lifecycle.print("ViewLifecycle").sink(receiveValue: {_ in })
viewModel.$state.subscribe(view)
view.lifecycle.subscribe(viewModel)

// MARK: - playground
PlaygroundPage.current.needsIndefiniteExecution = true
PlaygroundPage.current.liveView = view
