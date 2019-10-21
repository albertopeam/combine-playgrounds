import Combine
import Foundation
import PlaygroundSupport
import SwiftUI

enum TimeoutError: Error {
    case timedOut
}
let maxInterval = 5

let subject = PassthroughSubject<Void, TimeoutError>()
let timedOutSubject = subject.timeout(.seconds(maxInterval), scheduler: DispatchQueue.main)// it will send a finish event if nothing arrives before timeOut seconds. It will happen also between events, if after first event second event is dispatched 6 seconds later, then never will be emitted because after 5 seconds of the first one it will be finished
let timeOutErrorSubject = subject.timeout(.seconds(maxInterval), scheduler: DispatchQueue.main, customError: { TimeoutError.timedOut }) // if no events in the stablished timeout it will trigger the defined error


let timeline = TimelineView(title: "Button taps")
let timelineError = TimelineView(title: "Button taps, error if timeout")
let view = VStack(spacing: 100) {
    Button(action: { subject.send() }) {
        Text("Press me within 5 seconds")
    }
    timeline
    timelineError
}
PlaygroundPage.current.liveView = UIHostingController(rootView:
view)
timedOutSubject.displayEvents(in: timeline)
timeOutErrorSubject.displayEvents(in: timelineError)
