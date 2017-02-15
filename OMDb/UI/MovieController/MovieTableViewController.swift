//
//  MovieTableViewController.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 13.02.17.
//
//

import AlamofireImage
import RxCocoa
import RxRealm
import RxSwift
import UIKit

final class MovieTableViewController: UITableViewController {
  var model: DBMovie!

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = model.title

    if let poster = model.poster, let url = URL(string: poster) {
      let placeholderImage = UIImage(named: "imgPlaceholder")
      let imageView = UIImageView(image: placeholderImage)
      imageView.contentMode = .scaleAspectFit
      imageView.af_setImage(withURL: url, placeholderImage: placeholderImage)
      tableView.tableHeaderView = imageView
    }

    let tableFields = model.objectSchema.properties.filter { $0.name != "poster" }.map { $0.name }
    let tableModel = Observable.from(object: model)
      .map { model -> [MovieTableViewCell.Model] in
        return tableFields
          .filter { model[$0] != nil }
          .map { key -> MovieTableViewCell.Model in
            return (key: key, value: model[key] as! String)
          }
      }

    tableView.dataSource = nil
    tableModel.bindTo(tableView.rx.items) { tableView, row, model in
      let cell = tableView.dequeueReusableCell(cellClass: MovieTableViewCell.self)!
      cell.model = model
      return cell
    }
    .addDisposableTo(disposeBag)

    Network.loadMovieInfo(imdbID: model.imdbID, completion: {
      DBMovie.createOrUpdate(value: $0)
    }, noConnection: {
      showAlert(alertType: .networkError)
    })
  }
}
