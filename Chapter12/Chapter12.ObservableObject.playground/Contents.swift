import Combine
import Foundation
import UIKit
import PlaygroundSupport

class ViewModel: ObservableObject {
    enum State {
        case loading
        case success
        case error
    }
    
    @Published var state: State
    
    init(state: State = .loading) {
        self.state = state
    }
    
    func get() {
        state = .loading
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let self = self else { return }
            self.state = .success
        }
    }
}

class ViewController: UIViewController {
    private let label: UILabel = .init(frame: .zero)
    private var subscriptions = Set<AnyCancellable>()
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel = ViewModel()) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.widthAnchor.constraint(equalTo: view.widthAnchor)
        ])

        viewModel.objectWillChange.sink {  _ in
            print("objectWillChange") // we cannot access the current state of the object, because it was not changed yet
        }.store(in: &subscriptions)
        
        viewModel.$state.sink { [weak self] (newState) in
            guard let self = self else { return }
            switch newState {
            case .loading:
                print("Loading")
                self.label.text = "Loading"
            case .success:
                print("Success")
                self.label.text = "Success"
            case .error:
                print("Error")
                self.label.text = "Error"
            }
        }.store(in: &subscriptions)
        viewModel.get()
    }
}

PlaygroundPage.current.liveView = ViewController()
