//
//  UIViewController+Alert.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 15.02.17.
//
//

import UIKit

extension UIViewController {
  enum AlertType {
    case noConnection
    case networkError
  }

  func showAlert(alertType: AlertType) {
    let title: String
    let message: String
    let actions = [UIAlertAction(title: "OK", style: .default)]
    switch alertType {
    case .noConnection:
      title = "No network connection"
      message = "Please check your settings and make sure your device is connected to the Internet."
    case .networkError:
      title = "Network error"
      message = "Showing only local results."
    }

    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    actions.forEach { alert.addAction($0) }
    self.present(alert, animated: true)
  }
}
