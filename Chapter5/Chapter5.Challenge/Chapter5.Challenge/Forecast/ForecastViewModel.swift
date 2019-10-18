//
//  ForecastViewModel.swift
//  Chapter5.Challenge
//
//  Created by Alberto Penas Amor on 12/10/2019.
//  Copyright © 2019 com.github.albertopeam. All rights reserved.
//

import Foundation
import Combine

class ForecastViewModel: ObservableObject {    
    enum State: Equatable {
        case empty
        case loading
        case forecast(city: City)
        case error(error: ForecastRepository.Error)
        static func == (lhs: ForecastViewModel.State, rhs: ForecastViewModel.State) -> Bool {
            switch (lhs, rhs) {
            case (.empty, .empty): return true
            case (.loading, .loading): return true
            case (let .forecast(lhsCity), let .forecast(rhsCity)): return lhsCity == rhsCity
            case (let .error(lhsError), let .error(rhsError)): return lhsError == rhsError
            default: return false
            }
        }
    }
    private(set) var subscriptions = Set<AnyCancellable>()
    private let repository: ForecastRepository
    @Published var state: State
    
    init(repository: ForecastRepository = .init(), state: State = .empty) {
        self.repository = repository
        self.state = state
    }
    
    func getForecast() {
        if state == .loading {
            return
        }
        state = .loading
        repository.forecast()            
            .receive(on: RunLoop.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished: break
                case let .failure(error): self.state = .error(error: error)
                }
            }, receiveValue: {
                self.state = .forecast(city: $0)
            })
            .store(in: &subscriptions)
    }
}
