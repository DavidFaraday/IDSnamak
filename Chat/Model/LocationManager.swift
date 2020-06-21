//
//  LocationManager.swift
//  Chat
//
//  Created by David Kababyan on 20/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    
    var locationManager: CLLocationManager?
    var currentLocation: CLLocationCoordinate2D?

    private override init() {
        super.init()
        requestLocationAccess()
    }
    
    func requestLocationAccess() {
        
        if locationManager == nil {
            locationManager = CLLocationManager()
            locationManager!.delegate = self
            locationManager!.desiredAccuracy = kCLLocationAccuracyBest
            locationManager!.requestWhenInUseAuthorization()
        }
    }
    
    func startUpdating() {
        locationManager!.startUpdatingLocation()
    }
    
    func stopUpdating() {
        if locationManager != nil {
            locationManager!.stopUpdatingLocation()
        }
    }

    
    //MARK: - Delegates

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            print("Failed to get location")
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            break
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
            break
        case .authorizedAlways:
            manager.startUpdatingLocation()
            break
        case .restricted:
            // restricted by e.g. parental controls. User can't enable Location Services
            break
        case .denied:
            locationManager = nil
            print("Denied location")
            // user denied your app access to Location Services, but can grant access from Settings.app
            break
        @unknown default:
            print("Unknown Location error")
        }
    }
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        currentLocation = locations.last!.coordinate
    }

}
