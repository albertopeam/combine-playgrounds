import UIKit
import Combine
import SwiftUI
import PlaygroundSupport

let publishEvery = 1.0
let collectTimeStride = 4
let collectMaxCount = 2

let publisher = PassthroughSubject<Date, Never>()
let delayedPublisher = publisher
    .collect(.byTime(DispatchQueue.main, .seconds(collectTimeStride)))
    .flatMap({ $0.publisher })
let delayedPublisherByTimeOrCount = publisher
    .collect(.byTimeOrCount(DispatchQueue.main, .seconds(collectTimeStride), collectMaxCount))
    .flatMap({ $0.publisher })

let timer = Timer.publish(every: publishEvery, on: RunLoop.main, in: .common)
    .autoconnect()
    .subscribe(publisher)

let events = TimelineView(title: "Events")
let delayedEvents = TimelineView(title: "Collect Events every \(collectTimeStride) secs")
let delayedEventsByTimeOrCount = TimelineView(title: "Collect Events every \(collectTimeStride) secs or every \(collectMaxCount) events")

let rootView = VStack(spacing: 30) {
    events
    delayedEvents
    delayedEventsByTimeOrCount
}
PlaygroundPage.current.liveView = UIHostingController(rootView: rootView)

publisher.displayEvents(in: events)
delayedPublisher.displayEvents(in: delayedEvents)
delayedPublisherByTimeOrCount.displayEvents(in: delayedEventsByTimeOrCount)
