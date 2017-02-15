//
//  NSObject+Identifier.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 13.02.17.
//
//

import UIKit

extension UIView {
  static func classId() -> String {
    return String(describing: self)
  }
}
