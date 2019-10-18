import UIKit
import Combine
import SwiftUI
import PlaygroundSupport

let publishEvery = 1.0
let collectTimeStride = 4

let publisher = PassthroughSubject<Date, Never>()
let delayedPublisher = publisher
    .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride)))
    .flatMap({ $0.publisher })

let timer = Timer.publish(every: publishEvery, on: RunLoop.main, in: .common)
    .autoconnect()
    .subscribe(publisher)


let events = TimelineView(title: "Events")
let delayedEvents = TimelineView(title: "Collect Events every \(collectTimeStride) secs")

let rootView = VStack(spacing: 40) {
    events
    delayedEvents
}
PlaygroundPage.current.liveView = UIHostingController(rootView: rootView)

publisher.displayEvents(in: events)
delayedPublisher.displayEvents(in: delayedEvents)
