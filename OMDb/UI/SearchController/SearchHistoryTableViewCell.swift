//
//  SearchHistoryTableViewCell.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 14.02.17.
//
//

import UIKit

final class SearchHistoryTableViewCell: UITableViewCell {
  typealias Model = String

  var model: Model! {
    didSet {
      textLabel?.text = model
    }
  }
}
