//
//  WeatherIconService.swift
//  Weathery
//
//  Created by Никита Нагорный on 13.09.2025.
//

import UIKit

final class WeatherIconService {
    static func getWeatherIcon(from iconCode: String) -> (image: UIImage?, color: UIColor) {
        switch iconCode {
        case "01d": return (UIImage(systemName: "sun.max"), .systemOrange)
        case "01n": return (UIImage(systemName: "moon"), .systemGray)
        case "02d", "03d", "04d": return (UIImage(systemName: "cloud.sun"), .systemYellow)
        case "02n", "03n", "04n": return (UIImage(systemName: "cloud.moon"), .systemGray)
        case "09d", "10d": return (UIImage(systemName: "cloud.rain"), .systemBlue)
        case "09n", "10n": return (UIImage(systemName: "cloud.rain"), .systemBlue)
        case "11d", "11n": return (UIImage(systemName: "cloud.bolt"), .systemGray3)
        case "13d", "13n": return (UIImage(systemName: "snow"), .systemTeal)
        case "50d", "50n": return (UIImage(systemName: "cloud.fog"), .systemGray)
        default: return (UIImage(systemName: "questionmark"), .systemPink)
        }
    }
}
