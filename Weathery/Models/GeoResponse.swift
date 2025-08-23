//
//  GeoResponse.swift
//  Weathery
//
//  Created by Никита Нагорный on 23.08.2025.
//

import Foundation

struct GeoResponse: Codable {
    let name: String
    let lat: Double
    let lon: Double
    let country: String
}
