//
//  AnimationService.swift
//  Weathery
//
//  Created by Никита Нагорный on 14.09.2025.
//

import UIKit

final class AnimationService {
    static func animateWeatherElements(
        cityLabel: UILabel,
        temperatureLabel: UILabel,
        weatherIcon: UIImageView,
        weatherDescriptionLabel: UILabel,
        titleCollectionViewLabel: UILabel,
        daysCollectionView: UICollectionView,
        completion: (() -> Void)? = nil
    ) {
        cityLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        temperatureLabel.transform = CGAffineTransform(translationX: 0, y: 20)
        weatherIcon.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
        UIView.animate(withDuration: 0.6) {
            cityLabel.alpha = 1
            cityLabel.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut) {
            temperatureLabel.alpha = 1
            temperatureLabel.transform = .identity
        }
        
        UIView.animate(withDuration: 0.8, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.5) {
            weatherIcon.alpha = 1
            weatherIcon.transform = .identity
            weatherDescriptionLabel.alpha = 1
            titleCollectionViewLabel.alpha = 1
            daysCollectionView.alpha = 1
        } completion: { _ in
            completion?()
        }
    }
}
