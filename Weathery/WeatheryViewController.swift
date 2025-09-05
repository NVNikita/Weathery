//
//  ViewController.swift
//  Weathery
//
//  Created by Никита Нагорный on 19.08.2025.
//

import UIKit

protocol NetworkServiceProtocol {
    func getWeatherForCity(_ city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void)
    func getForecastForCity(_ city: String, completion: @escaping (Result<ForecastResponse, Error>) -> Void)
}

final class WeatheryViewController: UIViewController {
    
    private let cityLabel: UILabel = {
        let cityLabel = UILabel()
        cityLabel.font = .systemFont(ofSize: 38, weight: .light)
        cityLabel.textColor = .white
        return cityLabel
    }()
    
    private let temperatureLabel: UILabel = {
        let temperatureLabel = UILabel()
        temperatureLabel.font = .systemFont(ofSize: 48, weight: .light)
        temperatureLabel.textColor = .white
        return temperatureLabel
    }()
    
    private let weatherDescriptionLabel: UILabel = {
        let weatherDescriptionLabel = UILabel()
        weatherDescriptionLabel.font = .systemFont(ofSize: 18, weight: .light)
        weatherDescriptionLabel.textColor = .white
        return weatherDescriptionLabel
    }()
    
    private let titleCollectionViewLabel: UILabel = {
        let label = UILabel()
        label.text = "Прогноз на 5 дней"
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .white
        return label
    }()
    
    private let daysCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        return UICollectionView(frame: .zero, collectionViewLayout: layout)
    }()
    
    private let weatherIcon = UIImageView()
    private let activityIdicator = UIActivityIndicatorView(style: .large)
    private let searchController = UISearchController(searchResultsController: nil)
    private var forecastData: [ForecastResponse.ForecastItem] = []
    
    private let networkService: NetworkServiceProtocol
    private let weatheeryUserDefaults = WeatheryUserDefaults.shared
    
    init(weatherService: NetworkServiceProtocol) {
        self.networkService = weatherService
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemCyan
        
        setupUI()
        setupConsraints()
        setupSearchBar()
        loadCity()
    }
    
    private func setupUI() {
        view.addSubview(cityLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(weatherDescriptionLabel)
        view.addSubview(weatherIcon)
        view.addSubview(activityIdicator)
        view.addSubview(daysCollectionView)
        view.addSubview(titleCollectionViewLabel)
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        activityIdicator.translatesAutoresizingMaskIntoConstraints = false
        daysCollectionView.translatesAutoresizingMaskIntoConstraints = false
        titleCollectionViewLabel.translatesAutoresizingMaskIntoConstraints = false
        
        activityIdicator.color = .white
        
        daysCollectionView.register(DaysCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        
        daysCollectionView.layer.masksToBounds = true
        daysCollectionView.layer.cornerRadius = 25
        daysCollectionView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
    }
    
    private func setupConsraints() {
        NSLayoutConstraint.activate([
            cityLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            cityLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            
            temperatureLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            temperatureLabel.topAnchor.constraint(equalTo: cityLabel.bottomAnchor, constant: 25),
            
            weatherDescriptionLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherDescriptionLabel.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 5),
            
            weatherIcon.topAnchor.constraint(equalTo: weatherDescriptionLabel.bottomAnchor, constant: 50),
            weatherIcon.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            weatherIcon.widthAnchor.constraint(equalToConstant: 130),
            weatherIcon.heightAnchor.constraint(equalToConstant: 130),
            
            activityIdicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIdicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            daysCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            daysCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            daysCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            daysCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            titleCollectionViewLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleCollectionViewLabel.bottomAnchor.constraint(equalTo: daysCollectionView.topAnchor, constant: -5)
        ])
    }
    
    private func setupSearchBar() {
        searchController.searchBar.placeholder = "Поиск города"
        searchController.searchBar.searchBarStyle = .minimal
        
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "Готово"
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = .white
        
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func loadForecast(for city: String) {
        networkService.getForecastForCity(city) { [weak self] result in
            switch result {
            case .success(let forecast):
                self?.forecastData = self?.filterDailyForecast(forecast.list) ?? []
                self?.daysCollectionView.reloadData()
            case .failure(let error):
                print("Ошибка прогноза: \(error)")
            }
        }
    }
    
    private func getWeather(_ city: String) {
        activityIdicator.startAnimating()
        networkService.getWeatherForCity(city) { [ weak self ] result in
            guard let self else { return }
            DispatchQueue.main.async {
                switch result {
                case .success(let weather):
                    self.config(weather: weather)
                    self.activityIdicator.stopAnimating()
                case .failure(let error):
                    print("Error: \(error)")
                    self.showAllertError()
                    self.placeholderLoaderError()
                }
            }
        }
        loadForecast(for: city)
    }
    
    private func loadCity() {
        if let city = weatheeryUserDefaults.city {
            getWeather(city)
        } else {
            getWeather("Москва")
        }
    }
    
    private func config(weather: WeatherResponse) {
        cityLabel.text = weather.name
        temperatureLabel.text = "\(Int(weather.main.temp))°"
        weatherDescriptionLabel.text = weather.weather.first?.description ?? ""
        
        weatheeryUserDefaults.city = weather.name
        
        if let iconCode = weather.weather.first?.icon {
            let iconData = getWeatherIcon(from: iconCode)
            weatherIcon.image = iconData.image
            weatherIcon.tintColor = iconData.color
        }
    }
    
    private func showAllertError() {
        let alert = UIAlertController(title: "Ошибка",
                                      message: "Попробуйте позже",
                                      preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(action)
        
        present(alert, animated: true)
    }
    
    private func placeholderLoaderError() {
        self.cityLabel.text = "--"
        self.temperatureLabel.text = "--"
        self.weatherDescriptionLabel.text = "--"
        self.weatherIcon.image = UIImage(systemName: "questionmark")
        self.weatherIcon.tintColor = .systemPink
        self.weatherIcon.tintColor = .white
        self.activityIdicator.stopAnimating()
    }
    
    private func getDayOfWeek(from timestamp: TimeInterval) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateFormat = "EE"
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: date)
    }
    
    private func getWeatherIcon(from iconCode: String) -> (image: UIImage?, color: UIColor) {
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
    
    private func updateWeatherIcon(from iconCode: String) {
        let iconData = getWeatherIcon(from: iconCode)
        weatherIcon.image = iconData.image
        weatherIcon.tintColor = iconData.color
    }
    
    private func filterDailyForecast(_ list: [ForecastResponse.ForecastItem]) -> [ForecastResponse.ForecastItem] {
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

extension WeatheryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let city = searchBar.text, !city.isEmpty else { return }
        getWeather(city)
        searchBar.text = ""
        searchController.dismiss(animated: true)
        searchBar.resignFirstResponder()
    }
}

extension WeatheryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return forecastData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 15
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.bounds.width - 80) / 5
        return CGSize(width: width, height: collectionView.bounds.height - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as? DaysCollectionViewCell else {
            return UICollectionViewCell()
        }
        
        guard indexPath.item < forecastData.count else {
            cell.dayLabel.text = "--"
            cell.temperatureLabel.text = "--°"
            cell.iconImageView.image = UIImage(systemName: "questionmark")
            return cell
        }
        
        let forecastItem = forecastData[indexPath.item]
        
        cell.dayLabel.text = getDayOfWeek(from: forecastItem.dt)
        cell.temperatureLabel.text = "\(Int(forecastItem.main.temp))°"
        let weatherIcon = getWeatherIcon(from: forecastItem.weather.first?.icon ?? "")
        cell.iconImageView.image = weatherIcon.image
        cell.iconImageView.tintColor = weatherIcon.color
        
        cell.backgroundColor = .white
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 25
        
        return cell
    }
    
}
