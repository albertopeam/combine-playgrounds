import UIKit
import Combine
import PlaygroundSupport

class Button: UIButton {
    private let _tap: PassthroughSubject<Void, Never> = .init()

    var tap: AnyPublisher<Void, Never> {
        return _tap.eraseToAnyPublisher()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(run), for: .touchUpInside)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func run() {
        _tap.send(())
    }
}

class FormView: UIView {

    let button: Button = .init(frame: .init(x: 0, y: 0, width: 128, height: 40))

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        frame = CGRect.init(x: 0, y: 0, width: 480, height: 480)
        button.center = CGPoint.init(x: frame.midX, y: frame.midY)
        addSubview(button)
        button.setTitle("Tap me!", for: .normal)
        button.setTitleColor(.black, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FormViewModel: ObservableObject {

    private let tap: AnyPublisher<Void, Never>
    private var subscriptions = Set<AnyCancellable>()

    init(tap: AnyPublisher<Void, Never>) {
        self.tap = tap
        wireTap()
    }

    private func wireTap() {
        tap.sink(receiveValue: { print("Button tapped forwarded!") })
            .store(in: &subscriptions)
    }
}

let view = FormView()
//WAY ONE TO BIND VIEW WITH MODEL
let viewModel = FormViewModel(tap: view.button.tap)

//WAY TWO TO BIND VIEW WITH MODEL
let cancelable = view.button
    .tap
    .sink(receiveValue: { print("Button tapped directly!") })

PlaygroundPage.current.liveView = view
