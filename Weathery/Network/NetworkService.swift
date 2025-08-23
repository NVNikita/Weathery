//
//  NetworkService.swift
//  Weathery
//
//  Created by Никита Нагорный on 23.08.2025.
//

import UIKit

final class NetworkService {
    static let shared = NetworkService()
    private let key = "db73c335e9c874fa45904cf543671e0b"
    private let geoURL = "https://api.openweathermap.org/geo/1.0/direct"
    private let weatherURL = "https://api.openweathermap.org/data/2.5/weather"
    
    private init() {}
    
    func getCoordinates(for city: String, completion: @escaping (Result<[GeoResponse], Error>) -> Void) {
        guard var urlComponents = URLComponents(string: geoURL) else {
            print("Error in URLComponents geoURL")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "appid", value: key)
        ]
        
        guard let url = urlComponents.url else {
            completion(.failure(NetworkError.urlSessionError))
            print("Error in URL geoURL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.objectTask(for: request, completion: completion)
        task.resume()
    }
    
    func getWeather( lat: Double, lon: Double, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        guard var urlComponents = URLComponents(string: weatherURL) else {
            print("Error in URLComponents weatherURL")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "appid", value: key),
            URLQueryItem(name: "units", value: "metric"),
            URLQueryItem(name: "lang", value: "ru")
        ]
        
        guard let url = urlComponents.url else {
            print("Error in URL weatherURL")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        let task = URLSession.shared.objectTask(for: request, completion: completion)
        task.resume()
    }
}
