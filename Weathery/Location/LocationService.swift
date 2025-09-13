//
//  LocationService.swift
//  Weathery
//
//  Created by Никита Нагорный on 12.09.2025.
//

import CoreLocation

final class LocationService: NSObject, LocationServiceProtocol {
    
    weak var delegate: LocationServiceDelegate?
    
    private let locationManager: CLLocationManager
    private let geocoder: CLGeocoder
    private var currentGeocoder: CLGeocoder?
    
    override init() {
        self.locationManager = CLLocationManager()
        self.geocoder = CLGeocoder()
        super.init()
        self.locationManager.delegate = self
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    func requestLocation() {
        let status = locationManager.authorizationStatus
        
        switch status {
        case .notDetermined:
            requestAuthorization()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            delegate?.locationService(self, didFailWithError: LocationError.permissionDenied)
        @unknown default:
            break
        }
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func reverseGeocode(location: CLLocation, completion: @escaping (Result<String, Error>) -> Void) {
        currentGeocoder = geocoder
        
        geocoder.reverseGeocodeLocation(location) { [weak self] (placemarks, error) in
            self?.currentGeocoder = nil
            
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let placemark = placemarks?.first else {
                completion(.failure(LocationError.geocodingFailed))
                return
            }
            
            let city = placemark.locality ??
                      placemark.administrativeArea ??
                      placemark.name ??
                      LocationError.unknownCity.localizedDescription
            
            completion(.success(city))
        }
    }
}

// MARK: - CLLocationManagerDelegate
extension LocationService: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        manager.stopUpdatingLocation()
        guard let location = locations.last else { return }
        delegate?.locationService(self, didUpdateLocation: location)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        delegate?.locationService(self, didFailWithError: error)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        delegate?.locationService(self, didChangeAuthorization: manager.authorizationStatus)
    }
}

// MARK: - Errors
enum LocationError: LocalizedError {
    case permissionDenied
    case geocodingFailed
    case unknownCity
    
    var errorDescription: String? {
        switch self {
        case .permissionDenied:
            return "Доступ к геолокации запрещен"
        case .geocodingFailed:
            return "Не удалось определить город"
        case .unknownCity:
            return "Неизвестный город"
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .permissionDenied:
            return "Разрешите доступ к геолокации в Настройках"
        case .geocodingFailed, .unknownCity:
            return "Попробуйте ввести город вручную"
        }
    }
}
