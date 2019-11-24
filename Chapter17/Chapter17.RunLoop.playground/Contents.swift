import Combine
import Foundation
import PlaygroundSupport
import SwiftUI

let source =
    Timer.publish(every: 1.0, on: RunLoop.main, in: .common)
    .autoconnect()
    .scan(0, { previous, _ in previous + 1 })

let setupPublisher = { recorder in
    source
        .receive(on: DispatchQueue.global()) // it will receive in one of the available threads of the global pool
        .recordThread(using: recorder) // records in which thread is being emitted
        .receive(on: RunLoop.current) // thread that is being used when invoking this call
        .recordThread(using: recorder) // records in which thread is being emitted after the receive(on)
        .eraseToAnyPublisher()
}

let view = ThreadRecorderView(title: "Using ImmediateScheduler", setup: setupPublisher)
PlaygroundPage.current.liveView = UIHostingController(rootView: view)
