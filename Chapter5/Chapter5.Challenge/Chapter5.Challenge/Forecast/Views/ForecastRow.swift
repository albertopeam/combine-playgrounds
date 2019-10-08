//
//  ForecastRow.swift
//  Chapter5.Challenge
//
//  Created by Alberto Penas Amor on 12/10/2019.
//  Copyright © 2019 com.github.albertopeam. All rights reserved.
//

import SwiftUI

struct ForecastRow: View {
    let forecast: Forecast
    
    var body: some View {
        VStack {
            Text("\(forecast.date)").italic().foregroundColor(.gray)
            Image(forecast.icon)
            Text("\(forecast.temp)")
        }
    }
}
