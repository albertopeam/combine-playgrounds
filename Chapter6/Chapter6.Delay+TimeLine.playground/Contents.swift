import UIKit
import Combine
import SwiftUI
import PlaygroundSupport

let delaySec = 3
let publishEvery = 2.0

let publisher = PassthroughSubject<Date, Never>()
let delayedPublisher = publisher.delay(for: .seconds(delaySec), scheduler: DispatchQueue.main)

let timer = Timer.publish(every: publishEvery, on: RunLoop.main, in: .common)
    .autoconnect()
    .subscribe(publisher)


let events = TimelineView(title: "Events")
let delayedEvents = TimelineView(title: "Delayed Events")

let rootView = VStack(spacing: 40) {
    events
    delayedEvents
}
PlaygroundPage.current.liveView = UIHostingController(rootView: rootView)

publisher.displayEvents(in: events)
delayedPublisher.displayEvents(in: delayedEvents)
