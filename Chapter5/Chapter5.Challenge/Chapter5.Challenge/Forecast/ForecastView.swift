//
//  ContentView.swift
//  Chapter5.Challenge
//
//  Created by Alberto Penas Amor on 07/10/2019.
//  Copyright © 2019 com.github.albertopeam. All rights reserved.
//

import SwiftUI
import Combine

struct ForecastView: View {
    
    @ObservedObject var viewModel: ForecastViewModel
    
    init(viewModel: ForecastViewModel = .init()) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        switch self.viewModel.state {
        case .empty:
            return AnyView(EmptyView().onAppear(perform: { self.viewModel.getForecast()}))
        case .loading:
            return AnyView(ActivityIndicator(style: .large))
        case let .forecast(city):
            return AnyView(NavigationView(content: {
                List(city.forecast, id: \.dateTime) { forecast in
                    ForecastRow(forecast: forecast)
                }
                .navigationBarTitle(city.name)
                .navigationBarItems(trailing:
                    Button(action: {
                        self.viewModel.getForecast()
                    }, label: {
                        Image(systemName: "goforward")
                    })
                )
            }))
        case let .error(error):
            switch error {
            case .disabled:
                return AnyView(ErrorView(message: "Location is disabled", action: { self.viewModel.getForecast() }))
            case .noAuth:
                return AnyView(ErrorView(message: "Location permissions not accepted", action: { self.viewModel.getForecast() }))
            case .denied:
                return AnyView(ErrorView(message: "Location denied usage", action: { self.viewModel.getForecast() }))
            case .network, .noLocation:
                return AnyView(ErrorView(message: "Something went wrong", action: { self.viewModel.getForecast() }))
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ForecastView()
    }
}

