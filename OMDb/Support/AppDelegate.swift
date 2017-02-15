//
//  AppDelegate.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 10.02.17.
//
//

import AlamofireNetworkActivityIndicator
import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    NetworkActivityIndicatorManager.shared.isEnabled = true
    return true
  }
}

