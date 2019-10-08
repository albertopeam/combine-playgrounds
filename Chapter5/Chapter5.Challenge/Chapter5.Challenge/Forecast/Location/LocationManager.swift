//
//  LocationManager.swift
//  Chapter5.Challenge
//
//  Created by Alberto Penas Amor on 12/10/2019.
//  Copyright © 2019 com.github.albertopeam. All rights reserved.
//

import CoreLocation
import Combine

public class LocationManager: NSObject, CLLocationManagerDelegate {
    enum LocationError: Swift.Error {
        case disabled
        case noAuth
        case denied
        case noLocation
    }
    private let locationManager: CLLocationManager
    private var locationPublisher: PassthroughSubject<CLLocation, LocationError>
            
    init(locationManager: CLLocationManager = .init(),
         locationPublisher: PassthroughSubject<CLLocation, LocationError> = .init()) {
        self.locationManager = locationManager
        self.locationPublisher = locationPublisher
        super.init()
        locationManager.delegate = self
    }
    
    deinit {
        locationManager.delegate = nil
    }
    
    func oneShotLocation() -> AnyPublisher<CLLocation, LocationError> {
        defer {
            locationManager.requestWhenInUseAuthorization()
            locationManager.requestLocation()
        }
        locationPublisher = .init()
        return locationPublisher.eraseToAnyPublisher()
    }
    
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            locationPublisher.send(location)
        } else {
            locationPublisher.send(completion: .failure(.noLocation))
        }
    }
    
    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        if !CLLocationManager.locationServicesEnabled() {
            locationPublisher.send(completion: .failure(.disabled))
        } else {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                locationPublisher.send(completion: .failure(.noAuth))
            case .restricted, .denied:
                locationPublisher.send(completion: .failure(.denied))
            case .authorizedAlways, .authorizedWhenInUse:
                break
            @unknown default:
                fatalError()
            }
        }
    }
}
