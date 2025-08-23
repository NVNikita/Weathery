//
//  WeatherResponse.swift
//  Weathery
//
//  Created by Никита Нагорный on 23.08.2025.
//

import Foundation

struct WeatherResponse: Codable {
    let name: String
    let main: Main
    let weather: [Weather]
    
    struct Main: Codable {
        let temp: Double
    }
    
    struct Weather: Codable {
        let description: String
        let icon: String
    }
}
