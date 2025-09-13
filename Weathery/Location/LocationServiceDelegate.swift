//
//  LocationServiceDelegate.swift
//  Weathery
//
//  Created by Никита Нагорный on 13.09.2025.
//

import CoreLocation

protocol LocationServiceDelegate: AnyObject {
    func locationService(_ service: LocationServiceProtocol, didUpdateLocation location: CLLocation)
    func locationService(_ service: LocationServiceProtocol, didFailWithError error: Error)
    func locationService(_ service: LocationServiceProtocol, didChangeAuthorization status: CLAuthorizationStatus)
}
