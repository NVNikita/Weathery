//
//  ViewController.swift
//  Weathery
//
//  Created by Никита Нагорный on 19.08.2025.
//

import UIKit

final class WeatheryViewController: UIViewController {
    
    private let cityLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let weatherDescriptionLabel = UILabel()
    private let weatherIcon = UIImageView()
    private let activityIdicator = UIActivityIndicatorView(style: .large)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemCyan
        
        getWeather()
        setupUI()
        setupConsraints()
    }
    
    private func setupUI() {
        view.addSubview(cityLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(weatherDescriptionLabel)
        view.addSubview(weatherIcon)
        view.addSubview(activityIdicator)
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        activityIdicator.translatesAutoresizingMaskIntoConstraints = false
        
        cityLabel.font = .systemFont(ofSize: 34, weight: .light)
        cityLabel.textColor = .white
        
        temperatureLabel.font = .systemFont(ofSize: 48, weight: .light)
        temperatureLabel.textColor = .white
        
        weatherDescriptionLabel.font = .systemFont(ofSize: 18, weight: .light)
        weatherDescriptionLabel.textColor = .white
        
        weatherIcon.image = UIImage(systemName: "sun.max.fill") // Тест для верстки
        weatherIcon.tintColor = .systemYellow
        
        activityIdicator.color = .white
    }
    
    private func setupConsraints() {
        NSLayoutConstraint.activate([
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 30),
            
            weatherDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherDescriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 5),
            
            weatherIcon.topAnchor.constraint(equalTo: weatherDescriptionLabel.bottomAnchor, constant: 15),
            weatherIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherIcon.widthAnchor.constraint(equalToConstant: 100),
            weatherIcon.heightAnchor.constraint(equalToConstant: 100),
            
            activityIdicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIdicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    private func getWeather() {
        activityIdicator.startAnimating()
        NetworkService.shared.getWeatherForCity("Новокузнецк") { [ weak self ] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    let cityName = weather.name
                    let temperature = "\(Int(weather.main.temp))°"
                    let weatherDescription = weather.weather.first?.description ?? ""
                    self.config(city: cityName, temperature: temperature, weather: weatherDescription)
                    self.activityIdicator.stopAnimating()
                case .failure(let error):
                    print("Error: \(error)")
                }
            }
        }
    }
    
    private func config(city: String?, temperature: String?, weather: String?) {
        cityLabel.text = city
        temperatureLabel.text = temperature
        weatherDescriptionLabel.text = weather
    }
}

