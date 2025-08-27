//
//  NetworkService.swift
//  Weathery
//
//  Created by Никита Нагорный on 23.08.2025.
//

import UIKit

final class NetworkService: NetworkServiceProtocol {
    
    static let shared = NetworkService()
    
    private init() {}
    
    func getCoordinates(for city: String, completion: @escaping (Result<[GeoResponse], Error>) -> Void) {
        guard var urlComponents = URLComponents(string: APIConfig.geoURL.rawValue) else {
            print("Error in URLComponents geoURL")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "q", value: city),
            URLQueryItem(name: "limit", value: "1"),
            URLQueryItem(name: "appid", value: APIConfig.key.rawValue)
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
        guard var urlComponents = URLComponents(string: APIConfig.wearherURL.rawValue) else {
            print("Error in URLComponents weatherURL")
            completion(.failure(NetworkError.urlSessionError))
            return
        }
        
        urlComponents.queryItems = [
            URLQueryItem(name: "lat", value: "\(lat)"),
            URLQueryItem(name: "lon", value: "\(lon)"),
            URLQueryItem(name: "appid", value: APIConfig.key.rawValue),
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
    
    func getWeatherForCity(_ city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void) {
        getCoordinates(for: city) { [ weak self ] result in
            guard let self else { return }
            switch result {
            case .success(let geoData):
                guard let cityData = geoData.first else {
                    completion(.failure(NetworkError.noData))
                    return
                }
                
                self.getWeather(lat: cityData.lat, lon: cityData.lon) { weatherResult in
                    completion(weatherResult)
                }
            case .failure(let error):
                print("Error: \(error)")
                completion(.failure(error))
            }
        }
    }
}
