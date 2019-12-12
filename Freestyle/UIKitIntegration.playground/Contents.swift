import UIKit
import Combine
import PlaygroundSupport

class Button: UIButton {
    private var subscriptions = Set<AnyCancellable>()
    private let _tap: PassthroughSubject<Void, Never> = .init()
    var tap: AnyPublisher<Void, Never> {
        return _tap.eraseToAnyPublisher()
    }
    var isTapable: PassthroughSubject<Bool, Never> = .init()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(tapped), for: .touchUpInside)
        isTapable
            .assign(to: \.isEnabled, on: self)
            .store(in: &subscriptions)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func tapped() {
        _tap.send(())
    }
}

class TextField: UITextField {
    private let _changed: PassthroughSubject<String, Never> = .init()

    var changed: AnyPublisher<String, Never> {
        return _changed.eraseToAnyPublisher()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        addTarget(self, action: #selector(editingChanged), for: .editingChanged)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func editingChanged() {
        _changed.send(text ?? "")
    }

}

class FormView: UIView {

    let textField: TextField = .init(frame: .zero)
    let button: Button = .init(frame: .zero)

    init() {
        super.init(frame: .zero)
        backgroundColor = .white
        translatesAutoresizingMaskIntoConstraints = false

        button.translatesAutoresizingMaskIntoConstraints = false
        button.center = CGPoint(x: frame.midX, y: frame.midY)
        button.setTitle("Tap me!", for: .normal)
        button.setTitleColor(.black, for: .normal)
        button.setTitleColor(.gray, for: .disabled)
        addSubview(button)

        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "username >3 & <7"
        textField.textAlignment = .center
        textField.borderStyle = .roundedRect
        addSubview(textField)

        NSLayoutConstraint.activate([
            textField.centerXAnchor.constraint(equalTo: centerXAnchor),
            textField.bottomAnchor.constraint(equalTo: button.topAnchor, constant: -24),
            button.centerXAnchor.constraint(equalTo: centerXAnchor),
            button.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class FormViewModel: ObservableObject {

    private let text: AnyPublisher<String, Never>
    private let tap: AnyPublisher<Void, Never>
    private let isTapable: PassthroughSubject<Bool, Never>
    private var subscriptions = Set<AnyCancellable>()

    init(tap: AnyPublisher<Void, Never>, text: AnyPublisher<String, Never>, isTapable: PassthroughSubject<Bool, Never>) {
        self.tap = tap
        self.text = text
        self.isTapable = isTapable
        wire()
    }

    private func wire() {
        isTapable.send(false)

        text.map({ !$0.isEmpty })
            .sink(receiveValue: { self.isTapable.send($0) })
            .store(in: &subscriptions)
        tap.sink(receiveValue: { print("Button tapped!") })
            .store(in: &subscriptions)
    }
}

class ViewController: UIViewController {
    private let model: AnyObject

    init(view: UIView, model: AnyObject) {
        self.model = model
        super.init(nibName: nil, bundle: nil)
        self.view.addSubview(view)
        NSLayoutConstraint.activate([
            view.heightAnchor.constraint(equalTo: self.view.heightAnchor),
            view.widthAnchor.constraint(equalTo: self.view.widthAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//assembly process
let view = FormView()
let viewModel = FormViewModel(tap: view.button.tap, text: view.textField.changed, isTapable: view.button.isTapable)

PlaygroundPage.current.liveView = ViewController(view: view, model: viewModel)
