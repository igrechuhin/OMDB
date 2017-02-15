//
//  UIViewController+Hierarchy.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 15.02.17.
//
//

import UIKit

extension UIViewController {
  static func topViewController() -> UIViewController {
    let window = UIApplication.shared.delegate!.window!!
    return (window.rootViewController as! UINavigationController).topViewController!
  }
}
