//
//  DaysCollectionViewCell.swift
//  Weathery
//
//  Created by Никита Нагорный on 27.08.2025.
//

import UIKit

final class DaysCollectionViewCell: UICollectionViewCell {
    
    let dayLabel = UILabel()
    let temperatureLabel = UILabel()
    let iconImageView = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        contentView.addSubview(dayLabel)
        contentView.addSubview(temperatureLabel)
        contentView.addSubview(iconImageView)
        
        dayLabel.translatesAutoresizingMaskIntoConstraints = false
        temperatureLabel.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        
        dayLabel.font = .systemFont(ofSize: 15, weight: .light)
        dayLabel.textColor = .systemRed
        
        temperatureLabel.font = .systemFont(ofSize: 17, weight: .thin)
        temperatureLabel.textColor = .black
        
        NSLayoutConstraint.activate([
            temperatureLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            temperatureLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.bottomAnchor.constraint(equalTo: temperatureLabel.topAnchor, constant: -25),
            
            iconImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            iconImageView.topAnchor.constraint(equalTo: temperatureLabel.bottomAnchor, constant: 25)
        ])
    }
}
