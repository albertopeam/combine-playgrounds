import Combine
import Foundation
import SwiftUI
import PlaygroundSupport

let serialQueue = DispatchQueue(label: "Serial queue")
let sourceQueue = DispatchQueue.main
// let sourceQueue = sourceQueue // if we use source queue we shouldn´t have guaranteed which thread will be sending and receiving, but it is always the same, so there is an internal optimization to avoid thread change

let source = PassthroughSubject<Void, Never>()

let subscription = sourceQueue.schedule(after: sourceQueue.now, interval: .seconds(1)) {
    source.send(())
}

let setupPublisher = { recorder in
  source
    .recordThread(using: recorder)
    //.receive(on: serialQueue) // DispatchQueue makes no guarantee over which thread each work item executes on. It is a pool of threads and only can be done one operation at a time, but we have n threads
    .receive(on: serialQueue, options: DispatchQueue.SchedulerOptions(qos: .userInteractive)) // it can be used to prioritize this task over less important ones, in this case to draw UI
    .recordThread(using: recorder)
    .eraseToAnyPublisher()
}

let view = ThreadRecorderView(title: "Using DispatchQueue", setup: setupPublisher)
PlaygroundPage.current.liveView = UIHostingController(rootView: view)
