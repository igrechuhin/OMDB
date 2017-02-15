//
//  MovieTableViewCell.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 13.02.17.
//
//

import UIKit

final class MovieTableViewCell: UITableViewCell {
  typealias Model = (key: String, value: String)

  var model: Model! {
    didSet {
      textLabel?.text = model.key.capitalized
      detailTextLabel?.text = model.value
    }
  }
}
