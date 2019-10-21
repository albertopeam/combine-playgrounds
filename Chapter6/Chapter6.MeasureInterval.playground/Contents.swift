import Combine
import Foundation
import PlaygroundSupport
import SwiftUI

let nanos = 1_000_000_000.0

let subject = PassthroughSubject<String, Never>()
let measureInterval = subject.measureInterval(using: DispatchQueue.main) // DispatchQueue.main will send a DispatchQueue.SchedulerTimeType.Stride in nano seconds
let measureIntervalRunLoop = subject.measureInterval(using: RunLoop.main) // RunLoop.main will send a DispatchQueue.SchedulerTimeType.Stride in seconds

let subjectTimeline = TimelineView(title: "Emitted")
let measureTimeline = TimelineView(title: "Measured")
let view = VStack(spacing: 100) {
    subjectTimeline
    measureTimeline
}
PlaygroundPage.current.liveView = UIHostingController(rootView: view)
subject.displayEvents(in: subjectTimeline)
measureInterval.displayEvents(in: measureTimeline)

var subscriptions = Set<AnyCancellable>()
subject.sink {
    print("+\(deltaTime)s: Subject emitted: \($0)")
}.store(in: &subscriptions)
measureInterval.sink {
    let interval = Double($0.magnitude) / nanos
    print("+\(deltaTime)s: Measure emitted: \(interval)")
}.store(in: &subscriptions)
measureIntervalRunLoop.sink {
    print("+\(deltaTime)s: Measure Run Loop emitted: \($0)")
}.store(in: &subscriptions)

subject.feed(with: typingHelloWorld)
