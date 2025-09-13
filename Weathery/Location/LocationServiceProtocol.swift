//
//  LocationServiceProtocol.swift
//  Weathery
//
//  Created by Никита Нагорный on 12.09.2025.
//


import CoreLocation

protocol LocationServiceProtocol: AnyObject {
    var delegate: LocationServiceDelegate? { get set }
    func requestLocation()
    func requestAuthorization()
    func reverseGeocode(location: CLLocation, completion: @escaping (Result<String, Error>) -> Void)
}
