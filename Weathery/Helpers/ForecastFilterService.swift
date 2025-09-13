//
//  ForecastFilterService.swift
//  Weathery
//
//  Created by Никита Нагорный on 14.09.2025.
//

import Foundation

final class ForecastFilterService {
    static func filterDailyForecast(_ list: [ForecastResponse.ForecastItem]) -> [ForecastResponse.ForecastItem] {
        var dailyForecast: [ForecastResponse.ForecastItem] = []
        var addedDays: Set<String> = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        for item in list {
            let date = Date(timeIntervalSince1970: item.dt)
            let dayKey = dateFormatter.string(from: date)
            
            let calendar = Calendar.current
            let hour = calendar.component(.hour, from: date)
            
            if !addedDays.contains(dayKey) && hour >= 11 && hour <= 13 {
                dailyForecast.append(item)
                addedDays.insert(dayKey)
            }
            
            if dailyForecast.count >= 5 {
                break
            }
        }
        
        if dailyForecast.count < 5 {
            dailyForecast = []
            addedDays = []
            
            for item in list {
                let date = Date(timeIntervalSince1970: item.dt)
                let dayKey = dateFormatter.string(from: date)
                
                if !addedDays.contains(dayKey) {
                    dailyForecast.append(item)
                    addedDays.insert(dayKey)
                }
                
                if dailyForecast.count >= 5 {
                    break
                }
            }
        }
        return dailyForecast
    }
}
