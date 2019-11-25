import Combine
import Foundation
import PlaygroundSupport
import SwiftUI

let source =
    Timer.publish(every: 1.0, on: RunLoop.main, in: .common)
    .autoconnect()
    .scan(0, { previous, _ in previous + 1 })

var threadRecorder: ThreadRecorder? = nil

let setupPublisher = { (recorder: ThreadRecorder) in
    return source
        .receive(on: DispatchQueue.global()) // it will receive in one of the available threads of the global pool
        //.subscribe(on: DispatchQueue.global()) // as source is emitting on main thread, then we´ll receive from main
        .recordThread(using: recorder) // records in which thread is being emitted
        .receive(on: RunLoop.current) // thread that is being used when invoking this call, this case is main
        .recordThread(using: recorder) // records in which thread is being emitted after the receive(on)
        .handleEvents(receiveSubscription: { _ in threadRecorder = recorder })
        .eraseToAnyPublisher()
}

RunLoop.current
    .schedule(after: .init(Date(timeIntervalSinceNow: 5)),
              tolerance: .milliseconds(500)) {
                threadRecorder?.subscription?.cancel() // do cancel from RunLoop.current
    }

let view = ThreadRecorderView(title: "Using ImmediateScheduler", setup: setupPublisher)
PlaygroundPage.current.liveView = UIHostingController(rootView: view)
