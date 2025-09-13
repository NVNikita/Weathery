//
//  WeatherFormatter.swift
//  Weathery
//
//  Created by Никита Нагорный on 12.09.2025.
//

import Foundation

struct WeatherFormatter {
    static func temperature(_ temp: Double) -> String {
        "\(Int(temp))°"
    }
    
    static func dayOfWeek(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
}
