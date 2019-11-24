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
        //.delay(for: .seconds(10), scheduler: ImmediateScheduler.shared) // it won´t work because it will schedule inmediate
        // .delay(for: .seconds(3), scheduler: DispatchQueue.main) // it will work because DispatchQueue.main implements scheduler
        .recordThread(using: recorder) // records in which thread is being emitted
        //.receive(on: ImmediateScheduler.shared) // it will receive in the current thread
        .receive(on: DispatchQueue.global()) // it will receive in one of the available threads of the global pool
        .recordThread(using: recorder) // records in which thread is being emitted after the receive(on)
        .eraseToAnyPublisher()
}

let view = ThreadRecorderView(title: "Using ImmediateScheduler", setup: setupPublisher)
PlaygroundPage.current.liveView = UIHostingController(rootView: view)
