//
//  SearchTableVC+DZNEmptyDataSetSource.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 16.02.17.
//
//

import DZNEmptyDataSet
import UIKit

extension SearchTableVC: DZNEmptyDataSetSource {
  private enum EmptyState {
    case noResults
    case emptyRequest
    case emptyHistory
  }

  private func emptyState() -> EmptyState {
    let searchTextIsEmpty = searchController.searchBar.text!.isEmpty
    if searchTextIsEmpty {
      let searchHistoryIsEmpty = viewModel.isHistoryEmpty()
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
    let attributes: [String : Any] = [NSFontAttributeName: UIFont.boldSystemFont(ofSize: 18),
                                      NSForegroundColorAttributeName: UIColor.darkGray]

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

    let attributes: [String : Any] = [NSFontAttributeName: UIFont.systemFont(ofSize: 14),
                                      NSForegroundColorAttributeName: UIColor.lightGray,
                                      NSParagraphStyleAttributeName: paragraph]

    let description: String
    switch emptyState() {
    case .noResults: description = "Please change search string to get another try."
    case .emptyRequest: fallthrough
    case .emptyHistory: description = "This allows you to get info about any movie."
    }

    return NSAttributedString(string: description, attributes: attributes)
  }
}
