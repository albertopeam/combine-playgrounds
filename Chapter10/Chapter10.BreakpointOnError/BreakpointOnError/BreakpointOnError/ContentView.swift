//
//  ContentView.swift
//  BreakpointOnError
//
//  Created by Alberto Penas Amor on 28/10/2019.
//  Copyright © 2019 com.github.albertopeam. All rights reserved.
//

import Combine
import Foundation
import SwiftUI

class ContentViewModel {
    private var subscriptions = Set<AnyCancellable>()
    
    func get() {
        URLSession.shared
            .dataTaskPublisher(for: URL(string: "https://www.raywenderlich.es")!)
            .breakpoint(receiveSubscription: { (subscription) -> Bool in
                print("receiveSubscription")
                return true
            }, receiveOutput: { (_, _) -> Bool in
                print("receiveSubscription")
                return true // it can break only if certain values pass through the publisher
            }, receiveCompletion: { (_) -> Bool in
                print("receiveCompletion")
                return true
            })
            .breakpointOnError() // it will stop on the error throw
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                print("Sink received completion: \(completion)")
            }) { (data, _) in
                print("Sink received data: \(data)")
            }.store(in: &subscriptions)
    }
}

struct ContentView: View {
    private let viewModel: ContentViewModel
    
    init(viewModel: ContentViewModel = .init()) {
        self.viewModel = viewModel
    }
    var body: some View {
        Text("Hello World").onAppear {
            self.viewModel.get()
        }
    }
    
    
}
