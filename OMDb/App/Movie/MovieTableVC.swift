//
//  MovieTableVC.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 13.02.17.
//
//

import AlamofireImage
import RxCocoa
import RxSwift
import UIKit

final class MovieTableVC: UITableViewController {
  typealias Cell = MovieTableViewCell

  var viewModel: MovieTableVMProtocol!

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = viewModel.title

    if let url = viewModel.posterURL {
      let placeholderImage = UIImage(named: "imgPlaceholder")
      let imageView = UIImageView(image: placeholderImage)
      imageView.contentMode = .scaleAspectFit
      imageView.af_setImage(withURL: url, placeholderImage: placeholderImage)
      tableView.tableHeaderView = imageView
    }

    tableView.dataSource = nil
    viewModel.tableViewModel.bindTo(tableView.rx.items)
      { tableView, row, model in
        let cell = tableView.dequeueReusableCell(cellClass: Cell.self)!
        cell.model = model
        return cell
      }
      .addDisposableTo(disposeBag)

    viewModel.updateInfo()
  }
}
