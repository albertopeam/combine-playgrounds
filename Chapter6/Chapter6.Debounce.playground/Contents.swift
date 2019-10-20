import Combine
import UIKit
import SwiftUI
import PlaygroundSupport

let subject = PassthroughSubject<String, Never>()
let debounced = subject
    .debounce(for: .seconds(1), scheduler: DispatchQueue.main)
    .share() // DEBOUNCE: it will wait 1 sec until emit between events, then it will send the last value that it was sent to the publisher in the 1 sec interval if any => One value per second
    
let subjectTimeline = TimelineView(title: "Emitted values")
let debouncedTimeline = TimelineView(title: "Debounced values")

let view = VStack(spacing: 100) {
    subjectTimeline
    debouncedTimeline
}

PlaygroundPage.current.liveView = UIHostingController(rootView: view)

subject.displayEvents(in: subjectTimeline)
debounced.displayEvents(in: debouncedTimeline)

var subscriptions = Set<AnyCancellable>()
subject.sink { string in
  print("+\(deltaTime)s: Subject emitted: \(string)")
}.store(in: &subscriptions)
debounced.sink { string in
  print("+\(deltaTime)s: Debounced emitted: \(string)")
}.store(in: &subscriptions)

subject.feed(with: typingHelloWorld)

// If last value is sent and subject finishes before the debounce time has passed, this last value never will be sent to debounce
//DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
//    subject.send(completion: .finished)
//}
