//
//  ForecastRepository.swift
//  Chapter5.Challenge
//
//  Created by Alberto Penas Amor on 12/10/2019.
//  Copyright © 2019 com.github.albertopeam. All rights reserved.
//

import Foundation
import Combine
import CoreLocation

//TODO: test errors
//TODO: unit testing
class ForecastRepository {
    enum Error: Swift.Error, Equatable {
        case disabled
        case noAuth
        case denied
        case noLocation
        case network
    }
    private let urlSession: URLSession
    private let locationManager: LocationManager
    
    init(urlSession: URLSession = URLSession.shared, locationManager: LocationManager = .init()) {
        self.urlSession = urlSession
        self.locationManager = locationManager
    }
    
    //TODO: hide this two methods in a only method if possible
    func locationPublisher() -> AnyPublisher<CLLocation, Error> {
        return locationManager
            .oneShotLocation()
            .mapError({
                switch $0 {
                case .disabled:
                    return .disabled
                case .noAuth:
                    return .noAuth
                case .denied:
                    return .denied
                case .noLocation:
                    return .noLocation
                }
            }).eraseToAnyPublisher()
    }
    
    func forecastPublisher(location: CLLocation) -> AnyPublisher<City, Error> {
        let coordinate = location.coordinate
        let lat = coordinate.latitude
        let lon = coordinate.longitude
        let request = URLRequest(url: URL(string:"https://api.openweathermap.org/data/2.5/forecast/daily?lat=\(lat)&lon=\(lon)&cnt=17&units=metric&appid=b199ce0d1168c4d5a6517d4fdac3be6d")!)
        return self.urlSession
            .dataTaskPublisher(for: request)
            .map({ (data, response) -> Data in return data })
            .decode(type: DailyForecastsDecodable.self, decoder: JSONDecoder())
            .map({ $0.map() })
            .mapError({
                switch $0 {
                default:
                    return .network
                }
            })
            .eraseToAnyPublisher()
    }
}

private struct DailyForecastsDecodable: Decodable {
    let city: CityDecodable
    let list: [DailyForecastDecodable]
    func map() -> City {
        let forecast: [Forecast] = list.map({ Forecast(dateTime: Date(timeIntervalSince1970: $0.dt.interval),
                                                       icon: $0.weather.first?.icon ?? "",
                                                       temperature: $0.temp.day,
                                                       windSpeed: $0.speed,
                                                       windDegress: $0.deg,
                                                       humidity: $0.humidity,
                                                       cloudiness: $0.clouds) })
        return City.init(name: city.name, forecast: forecast)
    }
    struct CityDecodable: Decodable {
        let id: Int
        let name: String
        let country: String
        let coord: CoordinateDecodable
        struct CoordinateDecodable: Decodable {
            let lon: Double
            let lat: Double
        }
    }
    struct DailyForecastDecodable: Decodable {
        let dt: Int
        let sunrise: Int
        let sunset: Int
        let temp: TemperatureDecodable
        let weather: [WeatherDecodable]
        let pressure: Double
        let humidity: Int
        let speed: Double
        let deg: Int
        let clouds: Int
        let rain: Double?
        let snow: Double?
        struct TemperatureDecodable: Decodable {
            let day: Double
            let min: Double
            let max: Double
            let night: Double
            let eve: Double
            let morn: Double
        }
        struct WeatherDecodable: Decodable {
            let id: Int
            let main: String
            let description: String
            let icon: String
        }
    }
}
