//
//  AlertService.swift
//  Weathery
//
//  Created by Никита Нагорный on 13.09.2025.
//

import UIKit

final class AlertService {
    static func showErrorAlert(on viewController: UIViewController, title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        viewController.present(alert, animated: true)
    }
    
    static func showLocationDeniedAlert(on viewController: UIViewController) {
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
        
        viewController.present(alert, animated: true)
    }
}
