//
//  WeatheryUserDefaults.swift
//  Weathery
//
//  Created by Никита Нагорный on 05.09.2025.
//

import Foundation

final class WeatheryUserDefaults {
    
    static let shared = WeatheryUserDefaults()
    
    private init() {}
    
    private let cityKey: String = "cityKey"
    
    var city: String? {
        get {
            UserDefaults.standard.string(forKey: cityKey)
        } set {
            UserDefaults.standard.set(newValue, forKey: cityKey)
            UserDefaults.standard.synchronize()
        }
    }
}
