//
//  SearchMovieTableViewCell.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 13.02.17.
//
//

import AlamofireImage
import UIKit

final class SearchMovieTableViewCell: UITableViewCell {
  typealias Model = (title: String, poster: String?)

  var model: Model! {
    didSet {
      textLabel?.text = model.title

      if let imageView = imageView {
        imageView.contentMode = .scaleAspectFit
        let placeholderImage = UIImage(named: "imgPlaceholder")
        if let poster = model.poster, let url = URL(string: poster) {
          imageView.af_setImage(withURL: url, placeholderImage: placeholderImage)
        } else {
          imageView.image = placeholderImage
        }
      }
    }
  }

  override func prepareForReuse() {
    imageView?.af_cancelImageRequest()
  }
}
