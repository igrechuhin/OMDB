//
//  SearchTableVMProtocol.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 16.02.17.
//
//

import RealmSwift
import UIKit

protocol SearchTableVMProtocol {
  func getMovieTableVM(imdbID: String) -> MovieTableVMProtocol

  func getMovies(tableView: UITableView, title: String)
  func getHistory(tableView: UITableView)

  func isHistoryEmpty() -> Bool

  func searchMovies(title: String)
  func loadNextSearchPage()
}
