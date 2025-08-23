//
//  ViewController.swift
//  Weathery
//
//  Created by Никита Нагорный on 19.08.2025.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        NetworkService.shared.getWeatherForCity("Москва") { result in
            switch result {
            case .success(let weather):
                print("City: \(weather.name)")
                print("Temp: \(weather.main.temp)")
                print("Weather: \(weather.weather.first?.description ?? "")")
            case .failure(let error):
                print("Error: \(error)")
            }
        }
    }
}

