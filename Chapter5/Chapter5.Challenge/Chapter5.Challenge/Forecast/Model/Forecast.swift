//
//  Forecast.swift
//  Chapter5.Challenge
//
//  Created by Alberto Penas Amor on 12/10/2019.
//  Copyright © 2019 com.github.albertopeam. All rights reserved.
//

import Foundation

struct Forecast: Equatable {
    let dateTime: Date
    let icon: String
    let temperature: Double
    let windSpeed: Double
    let windDegress: Int
    let humidity: Int
    let cloudiness: Int
    
    var date: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "E dd"
        formatter.locale = Locale.current
        return formatter.string(from: dateTime)
    }
    
    var clouds: String {
        return "\(cloudiness)%"
    }
    
    var humidness: String {
        return "\(humidity)%"
    }
    
    var temp: String {
        let formatter = NumberFormatter()
        formatter.locale = Locale.current
        formatter.maximumFractionDigits = 1
        guard let result = formatter.string(for: temperature) else {
            return "-ºC"
        }
        return "\(result)ºC"
    }
}
