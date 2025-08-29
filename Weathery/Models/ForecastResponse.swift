//
//  ForecastResponse.swift
//  Weathery
//
//  Created by Никита Нагорный on 29.08.2025.
//

import Foundation

struct ForecastResponse: Codable {
    let list: [ForecastItem]
    let city: City
    
    struct ForecastItem: Codable {
        let dt: TimeInterval
        let main: Main
        let weather: [Weather]
        let dtTxt: String
        
        enum CodingKeys: String, CodingKey {
            case dt, main, weather
            case dtTxt = "dt_txt"
        }
    }
    
    struct Main: Codable {
        let temp: Double
        let feelsLike: Double
        let tempMin: Double
        let tempMax: Double
        
        enum CodingKeys: String, CodingKey {
            case temp
            case feelsLike = "feels_like"
            case tempMin = "temp_min"
            case tempMax = "temp_max"
        }
    }
    
    struct Weather: Codable {
        let id: Int
        let main: String
        let description: String
        let icon: String
    }
    
    struct City: Codable {
        let name: String
        let country: String
        let timezone: Int
    }
}
