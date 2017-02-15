//
//  SearchTableViewController.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 10.02.17.
//
//

import RxCocoa
import RxRealmDataSources
import RxSwift
import UIKit
import DZNEmptyDataSet

final class SearchTableViewController: UITableViewController {
  private struct Segue {
    static let Search2Movie = "Search2MovieSegue"
  }

  fileprivate let searchController = UISearchController(searchResultsController: nil)

  private var rxMoviesDataSource = RxTableViewRealmDataSource<DBMovie>(cellIdentifier: "") { dataSource, tableView, indexPath, model in
    let cell = tableView.dequeueReusableCell(cellClass: SearchMovieTableViewCell.self, indexPath: indexPath)
    cell.model = (title: model.title, poster: model.poster)
    return cell
  }

  private var rxHistoryDataSource = RxTableViewRealmDataSource<DBHistory>(cellIdentifier: "") { dataSource, tableView, indexPath, model in
    let cell = tableView.dequeueReusableCell(cellClass: SearchHistoryTableViewCell.self, indexPath: indexPath)
    cell.model = model.text
    return cell
  }

  private var totalItemsCount: Int?
  private var scheduleLoadNextSearchPage = false

  private var dataSourceDisposable: Disposable? {
    willSet { dataSourceDisposable?.dispose() }
    didSet { dataSourceDisposable?.addDisposableTo(disposeBag) }
  }
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
      .subscribe(onNext: { [unowned self] searchText in
        self.searchMovie(title: searchText)
      })
      .addDisposableTo(disposeBag)

    searchTextObservable
      .filter { !$0.isEmpty }
      .subscribe(onNext: { [unowned self] searchText in
        self.getMoviesFromDB(title: searchText)
      })
      .addDisposableTo(disposeBag)

    let cancelButtonClicked = rxSearchBar.cancelButtonClicked.asObservable()
    let searchTextCleared = searchTextObservable.filter { $0.isEmpty }.map { _ in () }
    Observable.of(cancelButtonClicked, searchTextCleared).merge()
      .subscribe(onNext: { [unowned self] in
        self.getHistoryFromDB()
      })
      .addDisposableTo(disposeBag)
  }

  private func getMoviesFromDB(title: String) {
    totalItemsCount = nil
    let movies = Observable.changeset(from: DBMovie.moviesWithTitleContaining(title))
    dataSourceDisposable = movies.bindTo(tableView.rx.realmChanges(rxMoviesDataSource))
  }

  private func getHistoryFromDB() {
    let requests = Observable.changeset(from: DBHistory.requests())
    dataSourceDisposable = requests.bindTo(tableView.rx.realmChanges(rxHistoryDataSource))
  }

  // MARK: - Search
  private func searchMovie(title: String) {
    Network.searchMovie(title: title, completion: { [weak self] in
      self?.searchResultsHandler(searchData: $0, totalItemsCount: $1)
      DBHistory.create(title: title)
    }, noConnection: {
      showAlert(alertType: .noConnection)
    })
  }

  private func loadNextSearchPage(localItemsCount: Int) {
    if let totalItemsCount = totalItemsCount, totalItemsCount != localItemsCount {
      scheduleLoadNextSearchPage = false
      Network.loadNextSearchPageIfAny(completion: { [weak self] in
        self?.searchResultsHandler(searchData: $0, totalItemsCount: $1)
        }, noConnection: {
          showAlert(alertType: .networkError)
      })
    } else {
      scheduleLoadNextSearchPage = true
    }
  }

  private func searchResultsHandler(searchData: [DBMovie.ValuesDict], totalItemsCount: Int) {
    DBMovie.createOrUpdate(values: searchData)
    self.totalItemsCount = totalItemsCount
    if scheduleLoadNextSearchPage {
      let localItemsCount = tableView.numberOfRows(inSection: 0)
      loadNextSearchPage(localItemsCount: localItemsCount)
    }
  }

  // MARK: - UITableViewDelegate
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    guard !searchController.searchBar.text!.isEmpty else { return }
    let localItemsCount = tableView.numberOfRows(inSection: 0)
    if indexPath.row == localItemsCount - 1 {
      loadNextSearchPage(localItemsCount: localItemsCount)
    }
  }

  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let cell = tableView.cellForRow(at: indexPath)
    if let cell = cell as? SearchMovieTableViewCell {
      performSegue(withIdentifier: Segue.Search2Movie, sender: cell.model)
    } else if let text = (cell as? SearchHistoryTableViewCell)?.model {
      let searchBar = searchController.searchBar
      searchBar.becomeFirstResponder()
      searchBar.text = text
      self.getMoviesFromDB(title: text)
    }
  }

  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    guard let identifier = segue.identifier else { return }
    switch identifier {
    case Segue.Search2Movie:
      let dvc = segue.destination as! MovieTableViewController
      let model = sender as! DBMovie
      dvc.model = model
      break
    default: break
    }
  }
}

extension SearchTableViewController: DZNEmptyDataSetSource {
  private enum EmptyState {
  case noResults
  case emptyRequest
  case emptyHistory
  }

  private func emptyState() -> EmptyState {
    let searchTextIsEmpty = searchController.searchBar.text!.isEmpty
    if searchTextIsEmpty {
      let searchHistoryIsEmpty = DBHistory.requests().isEmpty
      if searchHistoryIsEmpty {
        return .emptyHistory
      } else {
        return .emptyRequest
      }
    } else {
      return .noResults
    }
  }

  func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
    let imageName: String
    switch emptyState() {
    case .noResults: fallthrough
    case .emptyRequest: imageName = "imgSearchNotFound"
    case .emptyHistory: imageName = "imgSearchHistory"
    }

    return UIImage(named: imageName)
  }

  func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    let attributes: [String : Any] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18), NSForegroundColorAttributeName: UIColor.darkGray]

    let title: String
    switch emptyState() {
    case .noResults: title = "Sorry no movies found"
    case .emptyRequest: fallthrough
    case .emptyHistory: title = "Enter movie name to get results"
    }

    return NSAttributedString(string: title, attributes: attributes)
  }

  func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
    let paragraph = NSMutableParagraphStyle()
    paragraph.lineBreakMode = .byWordWrapping
    paragraph.alignment = .center

    let attributes: [String : Any] = [NSFontAttributeName: UIFont.systemFont(ofSize: 14), NSForegroundColorAttributeName: UIColor.lightGray, NSParagraphStyleAttributeName: paragraph]

    let description: String
    switch emptyState() {
    case .noResults: description = "Please change search string to get another try."
    case .emptyRequest: fallthrough
    case .emptyHistory: description = "This allows you to get info about any movie."
    }

    return NSAttributedString(string: description, attributes: attributes)
  }
}
