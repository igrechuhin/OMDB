//
//  UITableView+Cells.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 13.02.17.
//
//

import UIKit

extension UITableView {
  func dequeueReusableCell<T>(cellClass: T.Type) -> T? where T: UITableViewCell {
    return dequeueReusableCell(withIdentifier: cellClass.classId()) as! T?
  }

  func dequeueReusableCell<T>(cellClass: T.Type, indexPath: IndexPath) -> T where T: UITableViewCell {
    return dequeueReusableCell(withIdentifier: cellClass.classId(), for: indexPath) as! T
  }
}
