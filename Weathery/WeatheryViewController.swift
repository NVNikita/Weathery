//
//  WeatheryViewController.swift
//  Weathery
//
//  Created by Никита Нагорный on 19.08.2025.
//

import UIKit
import CoreLocation

protocol NetworkServiceProtocol {
    func getWeatherForCity(_ city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void)
    func getForecastForCity(_ city: String, completion: @escaping (Result<ForecastResponse, Error>) -> Void)
}

final class WeatheryViewController: UIViewController {
    
    // MARK: - UI Elements
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
    
    private let buttonLocation: UIButton = {
        let buttonLocation = UIButton()
        buttonLocation.setImage(UIImage(systemName: "location"), for: .normal)
        buttonLocation.tintColor = .white
        buttonLocation.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        buttonLocation.layer.masksToBounds = true
        buttonLocation.layer.cornerRadius = 21
        return buttonLocation
    }()
    
    private let weatherIcon = UIImageView()
    private let activityIndicator = UIActivityIndicatorView(style: .large)
    private let searchController = UISearchController(searchResultsController: nil)
    
    // MARK: - Properties
    private let networkService: NetworkServiceProtocol
    private let locationService: LocationServiceProtocol
    private let weatherUserDefaults = WeatheryUserDefaults.shared
    
    private var isFetchingData = false
    private var forecastData: [ForecastResponse.ForecastItem] = []
    private var flag: Bool = true
    
    // MARK: - Initialization
    init(weatherService: NetworkServiceProtocol, locationService: LocationServiceProtocol = LocationService()) {
        self.networkService = weatherService
        self.locationService = locationService
        super.init(nibName: nil, bundle: nil)
        self.locationService.delegate = self
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemCyan
        
        setupUI()
        setupConstraints()
        setupSearchBar()
        loadCity()
    }
    
    // MARK: - Setup Methods
    private func setupUI() {
        view.addSubview(cityLabel)
        view.addSubview(temperatureLabel)
        view.addSubview(weatherDescriptionLabel)
        view.addSubview(weatherIcon)
        view.addSubview(activityIndicator)
        view.addSubview(daysCollectionView)
        view.addSubview(titleCollectionViewLabel)
        view.addSubview(buttonLocation)
        
        cityLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherDescriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        weatherIcon.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        daysCollectionView.translatesAutoresizingMaskIntoConstraints = false
        titleCollectionViewLabel.translatesAutoresizingMaskIntoConstraints = false
        buttonLocation.translatesAutoresizingMaskIntoConstraints = false
        
        activityIndicator.color = .white
        
        daysCollectionView.register(DaysCollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        
        buttonLocation.addTarget(self, action: #selector(buttonLocationTapped), for: .touchUpInside)
        
        daysCollectionView.layer.masksToBounds = true
        daysCollectionView.layer.cornerRadius = 25
        daysCollectionView.backgroundColor = UIColor.white.withAlphaComponent(0.3)
        
        cityLabel.alpha = 0
        temperatureLabel.alpha = 0
        weatherDescriptionLabel.alpha = 0
        weatherIcon.alpha = 0
        titleCollectionViewLabel.alpha = 0
    }
    
    private func setupConstraints() {
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
            
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            daysCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            daysCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            daysCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            daysCollectionView.heightAnchor.constraint(equalToConstant: 200),
            
            titleCollectionViewLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            titleCollectionViewLabel.bottomAnchor.constraint(equalTo: daysCollectionView.topAnchor, constant: -5),
            
            buttonLocation.heightAnchor.constraint(equalToConstant: 44),
            buttonLocation.widthAnchor.constraint(equalToConstant: 44),
            buttonLocation.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonLocation.bottomAnchor.constraint(equalTo: daysCollectionView.topAnchor, constant: -20)
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
    
    // MARK: - Data Methods
    private func loadForecast(for city: String) {
        networkService.getForecastForCity(city) { [weak self] result in
            switch result {
            case .success(let forecast):
                self?.forecastData = self?.filterDailyForecast(forecast.list) ?? []
                DispatchQueue.main.async {
                    self?.daysCollectionView.reloadData()
                    self?.flag = true
                }
            case .failure(let error):
                self?.flag = false
                print("Ошибка прогноза: \(error)")
            }
        }
    }
    
    private func getWeather(_ city: String) {
        guard !isFetchingData else { return }
        isFetchingData = true
        activityIndicator.startAnimating()
        
        networkService.getWeatherForCity(city) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isFetchingData = false
                switch result {
                case .success(let weather):
                    self.config(weather: weather)
                    self.activityIndicator.stopAnimating()
                    self.loadForecast(for: city)
                case .failure(let error):
                    print("Error: \(error)")
                    self.showAlertError()
                    self.placeholderLoaderError()
                }
            }
        }
    }
    
    private func loadCity() {
        if let city = weatherUserDefaults.city {
            getWeather(city)
        } else {
            getWeather("Москва")
        }
    }
    
    // MARK: - UI Methods
    private func animateElements() {
        self.cityLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        self.temperatureLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        self.weatherIcon.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.6) {
            self.cityLabel.alpha = 1
            self.cityLabel.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut) {
            self.temperatureLabel.alpha = 1
            self.temperatureLabel.transform = .identity
        }
        
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            self.weatherIcon.alpha = 1
            self.weatherIcon.transform = .identity
            self.weatherDescriptionLabel.alpha = 1
            self.titleCollectionViewLabel.alpha = 1
            self.daysCollectionView.alpha = 1
        }
    }
    
    private func config(weather: WeatherResponse) {
        cityLabel.text = weather.name
        temperatureLabel.text = WeatherFormatter.temperature(weather.main.temp)
        weatherDescriptionLabel.text = weather.weather.first?.description ?? ""
        
        weatherUserDefaults.city = weather.name
        
        if let iconCode = weather.weather.first?.icon {
            let iconData = getWeatherIcon(from: iconCode)
            weatherIcon.image = iconData.image
            weatherIcon.tintColor = iconData.color
        }
        animateElements()
    }
    
    private func showAlertError() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Попробуйте позже",
            preferredStyle: .alert
        )
        
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
        self.activityIndicator.stopAnimating()
        
        self.forecastData = []
        self.flag = false
        self.daysCollectionView.reloadData()
        
        UIView.animate(withDuration: 0.4) {
            self.cityLabel.alpha = 1
            self.temperatureLabel.alpha = 1
            self.weatherDescriptionLabel.alpha = 1
            self.weatherIcon.alpha = 1
        }
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
    
    // MARK: - Actions
    @objc private func buttonLocationTapped() {
        locationService.requestLocation()
    }
    
    private func startLocationUpdate() {
        activityIndicator.startAnimating()
        locationService.requestLocation()
    }
    
    private func showLocationDeniedAlert() {
        let alert = UIAlertController(
            title: "Доступ к геолокации запрещен",
            message: "Разрешите доступ к геолокации в Настройках > Конфиденциальность > Службы геолокации",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        alert.addAction(UIAlertAction(title: "Настройки", style: .default) { _ in
            if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(settingsURL)
            }
        })
        
        present(alert, animated: true)
    }
    
    private func handleLocation(_ location: CLLocation) {
        locationService.reverseGeocode(location: location) { [weak self] result in
            DispatchQueue.main.async {
                self?.activityIndicator.stopAnimating()
                
                switch result {
                case .success(let city):
                    self?.getWeather(city)
                case .failure(let error):
                    print("Ошибка геокодирования: \(error.localizedDescription)")
                    self?.showGeocodingErrorAlert()
                }
            }
        }
    }
    
    private func showGeocodingErrorAlert() {
        let alert = UIAlertController(
            title: "Ошибка",
            message: "Не удалось определить ваш город",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UISearchBarDelegate
extension WeatheryViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let city = searchBar.text?.trimmingCharacters(in: .whitespacesAndNewlines),
              !city.isEmpty else { return }
        
        getWeather(city)
        searchBar.text = ""
        searchController.dismiss(animated: true)
        searchBar.resignFirstResponder()
    }
}

// MARK: - UICollectionViewDataSource & Delegate
extension WeatheryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 5
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
        
        if forecastData.isEmpty || !flag {
            cell.dayLabel.text = ""
            cell.temperatureLabel.text = "?"
            cell.temperatureLabel.textColor = .systemRed
            cell.iconImageView.image = nil
            cell.backgroundColor = .white
            cell.layer.masksToBounds = true
            cell.layer.cornerRadius = 25
            return cell
        }
        
        guard indexPath.item < forecastData.count else {
            cell.dayLabel.text = "?"
            cell.temperatureLabel.text = "?°"
            cell.iconImageView.image = UIImage(systemName: "questionmark")
            cell.iconImageView.tintColor = .systemRed
            return cell
        }
        
        let forecastItem = forecastData[indexPath.item]
        
        cell.dayLabel.text = WeatherFormatter.dayOfWeek(from: forecastItem.dt)
        cell.temperatureLabel.text = WeatherFormatter.temperature(forecastItem.main.temp)
        let weatherIcon = getWeatherIcon(from: forecastItem.weather.first?.icon ?? "")
        cell.iconImageView.image = weatherIcon.image
        cell.iconImageView.tintColor = weatherIcon.color
        
        cell.backgroundColor = .white
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 25
        
        return cell
    }
}

// MARK: - LocationServiceDelegate
extension WeatheryViewController: LocationServiceDelegate {
    func locationService(_ service: LocationServiceProtocol, didUpdateLocation location: CLLocation) {
        handleLocation(location)
    }
    
    func locationService(_ service: LocationServiceProtocol, didFailWithError error: Error) {
        DispatchQueue.main.async {
            self.activityIndicator.stopAnimating()
            print("Ошибка получения локации: \(error.localizedDescription)")
            
            let alert = UIAlertController(
                title: "Ошибка",
                message: "Не удалось получить ваше местоположение",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default))
            self.present(alert, animated: true)
        }
    }
    
    func locationService(_ service: LocationServiceProtocol, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            startLocationUpdate()
        case .denied, .restricted:
            activityIndicator.stopAnimating()
            showLocationDeniedAlert()
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }
}
