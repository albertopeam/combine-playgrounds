//
//  ContentViewModel.swift
//  ReplaySubject
//
//  Created by Alberto Penas Amor on 10/03/2020.
//  Copyright © 2020 com.github.albertopeam. All rights reserved.
//

import Foundation
import Combine

class ContentViewModel: ObservableObject {
    struct Model {
        let title: String
        let url: URL
    }
    let subject: ReplaySubject<[Model], Never> = .init(1)

    init() {
        let items: [Model] = [
            .init(title: "Real time viewer", url: URL(string: "https://github.com/SuprHackerSteve/Crescendo")!),
            .init(title: "Corona Tracker", url: URL(string: "https://github.com/MhdHejazi/CoronaTracker")!),
            .init(title: "RSS reader", url: URL(string: "https://github.com/Ranchero-Software/NetNewsWire")!),
            .init(title: "Bottom sheets", url: URL(string: "https://github.com/slackhq/PanModal")!),
            .init(title: "Code Generator", url: URL(string: "https://github.com/SwiftGen/SwiftGen")!),
            .init(title: "Network abstraction layer", url: URL(string: "https://github.com/Moya/Moya")!),
            .init(title: "Matcher Framework ", url: URL(string: "https://github.com/Quick/Nimble")!),
            .init(title: "Convert videos to high-quality GIFs", url: URL(string: "https://github.com/sindresorhus/Gifski")!),
            .init(title: "Web sockets", url: URL(string: "https://github.com/daltoniam/Starscream")!),
            .init(title: "Dependency injection", url: URL(string: "https://github.com/Swinject/Swinject")!)
        ]
        subject.send(items)
        subject.send(completion: .finished)
    }
}
