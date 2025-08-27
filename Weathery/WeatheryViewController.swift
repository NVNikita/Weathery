//
//  ViewController.swift
//  Weathery
//
//  Created by Никита Нагорный on 19.08.2025.
//

import UIKit

protocol WeatherServiceProtocol {
    func getWeatherForCity(_ city: String, completion: @escaping (Result<WeatherResponse, Error>) -> Void)
}

final class WeatheryViewController: UIViewController {
    
    private let cityLabel: UILabel = {
        let cityLabel = UILabel()
        cityLabel.font = .systemFont(ofSize: 34, weight: .light)
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
    
    private let weatherService: WeatherServiceProtocol
    
    init(weatherService: WeatherServiceProtocol) {
        self.weatherService = weatherService
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
        getWeather("Москва")
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
        
        weatherIcon.image = UIImage(systemName: "sun.max.fill") // MOCK
        weatherIcon.tintColor = .systemYellow
        
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
            weatherIcon.widthAnchor.constraint(equalToConstant: 150),
            weatherIcon.heightAnchor.constraint(equalToConstant: 150),
            
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
        
        searchController.searchBar.delegate = self
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    
    private func getWeather(_ city: String) {
        activityIdicator.startAnimating()
        weatherService.getWeatherForCity(city) { [ weak self ] result in
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

extension WeatheryViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        5
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
        
        cell.backgroundColor = .white
        cell.layer.masksToBounds = true
        cell.layer.cornerRadius = 25
        cell.dayLabel.text = "Mon" // MOCK
        cell.temperatureLabel.text = "20°" //MOCK
        cell.iconImageView.image = UIImage(systemName: "sun.max") //MOCK
        return cell
    }
    
}
