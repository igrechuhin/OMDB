//
//  SearchTableVM.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 16.02.17.
//
//

import RealmSwift
import RxRealmDataSources
import RxSwift
import UIKit

final class SearchTableVM: SearchTableVMProtocol {
  private var totalItemsCount: Int?
  private var lastLoadedPage = 0
  private var loading = false
  private var scheduleLoad = false
  private var title: String!

  private var dataSourceDisposable: Disposable? {
    willSet { dataSourceDisposable?.dispose() }
    didSet { dataSourceDisposable?.addDisposableTo(disposeBag) }
  }
  private let disposeBag = DisposeBag()

  private let moviesDataSource = RxTableViewRealmDataSource<DBMovie>(cellIdentifier: "")
    { dataSource, tableView, indexPath, model in
      let cellClass = SearchTableVC.MovieCell.self
      let cell = tableView.dequeueReusableCell(cellClass: cellClass, indexPath: indexPath)
      cell.model = (imdbID: model.imdbID, title: model.title, poster: model.poster)
      return cell
    }

  private let historyDataSource = RxTableViewRealmDataSource<DBHistory>(cellIdentifier: "")
    { dataSource, tableView, indexPath, model in
      let cellClass = SearchTableVC.HistoryCell.self
      let cell = tableView.dequeueReusableCell(cellClass: cellClass, indexPath: indexPath)
      cell.model = model.text
      return cell
    }

  func getMovieTableVM(imdbID: String) -> MovieTableVMProtocol {
    let movie = DBMovie.getMovie(imdbID: imdbID)
    return MovieTableVM(model: movie)
  }

  func getMovies(tableView: UITableView, title: String) {
    let movies = DBMovie.moviesWithTitleContaining(title)
    let moviesObservable = Observable.changeset(from: movies)
    dataSourceDisposable = moviesObservable.bindTo(tableView.rx.realmChanges(moviesDataSource))
  }

  func getHistory(tableView: UITableView) {
    let history = DBHistory.requests()
    let historyObservable = Observable.changeset(from: history)
    dataSourceDisposable = historyObservable.bindTo(tableView.rx.realmChanges(historyDataSource))
  }

  func isHistoryEmpty() -> Bool {
    return DBHistory.requests().isEmpty
  }

  func searchMovies(title: String) {
    totalItemsCount = nil
    lastLoadedPage = 0
    loading = false
    scheduleLoad = false
    self.title = title
    loadNextSearchPage()
  }

  func loadNextSearchPage() {
    guard loading == false else {
      scheduleLoad = true
      return
    }
    guard let title = title, !title.isEmpty else { return }
    let localItemsCount = DBMovie.moviesWithTitleContaining(title).count
    guard totalItemsCount != localItemsCount else { return }
    loading = true
    scheduleLoad = false
    Network.loadSearchPage(title: title, page: lastLoadedPage + 1,
      onComplete: { [weak self, title] searchData, totalItemsCount in
        DBHistory.create(title: title)
        DBMovie.createOrUpdate(values: searchData)
        guard let s = self else { return }
        s.totalItemsCount = totalItemsCount
        s.lastLoadedPage += 1
        s.loading = false
        if s.scheduleLoad {
          s.loadNextSearchPage()
        }
      }, onError: { error in
        switch error {
        case .noConnection:
          UIViewController.showAlert(alertType: .noConnection)
        case .invalidResponse: fallthrough
        case .other(_):
          UIViewController.showAlert(alertType: .networkError)
        }
      })
  }
}
