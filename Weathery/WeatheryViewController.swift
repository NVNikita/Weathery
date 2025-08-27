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
    private let searchController = UISearchController(searchResultsController: nil)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemCyan
        
        setupUI()
        setupConsraints()
        setupSearchBar()
        getWeather("Москва")
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
    
    private func setupSearchBar() {
        searchController.searchBar.placeholder = "Поиск города"
        searchController.searchBar.searchBarStyle = .minimal
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func getWeather(_ city: String) {
        activityIdicator.startAnimating()
        NetworkService.shared.getWeatherForCity(city) { [ weak self ] result in
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
                    self.showAllertError()
                    print("Error: \(error)")
                    self.config(city: "Ошибка", temperature: "°-°", weather: "обыденно")
                    self.weatherIcon.tintColor = .white
                    self.activityIdicator.stopAnimating()
                }
            }
        }
    }
    
    private func config(city: String?, temperature: String?, weather: String?) {
        cityLabel.text = city
        temperatureLabel.text = temperature
        weatherDescriptionLabel.text = weather
    }
    
    private func showAllertError() {
        let alert = UIAlertController(title: "Ошибка",
                                      message: "Попробуйте позже",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        
        present(alert, animated: true)
    }
}

extension WeatheryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let city = searchBar.text, !city.isEmpty else { return }
        getWeather(city)
        searchBar.text = ""
        searchController.dismiss(animated: true)
        searchBar.resignFirstResponder()
    }
}
