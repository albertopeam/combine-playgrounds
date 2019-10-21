import Combine
import UIKit
import SwiftUI
import PlaygroundSupport

let throttleTimeMax = 1

let subject = PassthroughSubject<String, Never>()
let throttled = subject
    .throttle(for: .seconds(throttleTimeMax), scheduler: DispatchQueue.main, latest: false) // it will admit 1 val per throttle time, and it will be the first of the received, if latest: true, it will be the latest of the received
    .share()

let subjectTimeline = TimelineView(title: "Emitted values")
let debouncedTimeline = TimelineView(title: "Throttled values")

let view = VStack(spacing: 100) {
    subjectTimeline
    debouncedTimeline
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view)

subject.displayEvents(in: subjectTimeline)
throttled.displayEvents(in: debouncedTimeline)

var subscriptions = Set<AnyCancellable>()
subject.sink { string in
  print("+\(deltaTime)s: Subject emitted: \(string)")
}.store(in: &subscriptions)
throttled.sink { string in
  print("+\(deltaTime)s: Throttled emitted: \(string)")
}.store(in: &subscriptions)

subject.feed(with: typingHelloWorld)
