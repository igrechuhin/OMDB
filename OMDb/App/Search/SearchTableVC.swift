//
//  SearchTableVC.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 10.02.17.
//
//

import RxCocoa
import RxSwift
import UIKit

final class SearchTableVC: UITableViewController {
  typealias MovieCell = SearchMovieTableViewCell
  typealias HistoryCell = SearchHistoryTableViewCell

  private struct Segue {
    static let Search2Movie = "Search2MovieSegue"
  }

  let searchController = UISearchController(searchResultsController: nil)

  let viewModel: SearchTableVMProtocol = SearchTableVM()

  private let disposeBag = DisposeBag()

  override func viewDidLoad() {
    super.viewDidLoad()

    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true

    let searchBar = searchController.searchBar
    tableView.tableHeaderView = searchBar

    let rxSearchBar = searchBar.rx

    let searchTextBeginEditing = rxSearchBar.textDidBeginEditing.map { [searchBar] in searchBar.text }
    let searchText = rxSearchBar.text.asObservable()
    let searchTextObservable = Observable.of(searchTextBeginEditing, searchText).merge()
      .filter { $0 != nil}
      .map { $0!.trimmingCharacters(in: .whitespacesAndNewlines) }

    searchTextObservable
      .throttle(0.5, scheduler: SerialDispatchQueueScheduler(qos: .default))
      .distinctUntilChanged { $0 == $1 }
      .filter { $0.characters.count > 2 }
      .subscribe(onNext: { [viewModel] searchText in
        viewModel.searchMovies(title: searchText)
      })
      .addDisposableTo(disposeBag)

    searchTextObservable
      .filter { !$0.isEmpty }
      .subscribe(onNext: { [viewModel, tableView] searchText in
        viewModel.getMovies(tableView: tableView!, title: searchText)
      })
      .addDisposableTo(disposeBag)

    let cancelButtonClicked = rxSearchBar.cancelButtonClicked.asObservable()
    let searchTextCleared = searchTextObservable.filter { $0.isEmpty }.map { _ in () }
    Observable.of(cancelButtonClicked, searchTextCleared).merge()
      .subscribe(onNext: { [viewModel, tableView] in
        viewModel.getHistory(tableView: tableView!)
      })
      .addDisposableTo(disposeBag)
  }

  // MARK: - UITableViewDelegate
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard !searchController.searchBar.text!.isEmpty else { return }
    let localItemsCount = tableView.numberOfRows(inSection: 0)
    if indexPath.row == localItemsCount - 1 {
      viewModel.loadNextSearchPage()
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    switch cell {
    case let cell as MovieCell:
      performSegue(withIdentifier: Segue.Search2Movie, sender: cell.model)
    case let cell as HistoryCell:
      if let text = cell.model {
        let searchBar = searchController.searchBar
        searchBar.becomeFirstResponder()
        searchBar.text = text
        viewModel.getMovies(tableView: tableView, title: text)
      }
    default: assert(false)
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }
    switch identifier {
    case Segue.Search2Movie:
      let dvc = segue.destination as! MovieTableVC
      let imdbID = (sender as! MovieCell.Model).imdbID
      dvc.viewModel = viewModel.getMovieTableVM(imdbID: imdbID)
      break
    default: break
    }
  }
}
