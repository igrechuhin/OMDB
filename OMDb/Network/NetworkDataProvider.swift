//
//  NetworkDataProvider.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 14.02.17.
//
//

import UIKit

protocol NetworkDataProvider {
  typealias StringArray = [String]
  typealias SearchHandler = ([DBMovie.ValuesDict], Int) -> Void
  typealias InfoHandler = (DBMovie.ValuesDict) -> Void

  func searchMovie(title: String, completion: @escaping SearchHandler)

  func loadNextSearchPageIfAny(completion: @escaping SearchHandler)

  func loadMovieInfo(imdbID: String, completion: @escaping InfoHandler)

  func errorHandler(_ error: Error)

  func normalizedResults(_ results: DBMovie.ValuesDict, keysMap: DBMovie.ValuesDict, ignoreValues: StringArray) -> DBMovie.ValuesDict
}

extension NetworkDataProvider {
  func errorHandler(_ error: Error) {
    UIViewController.topViewController().showAlert(alertType: .networkError)
  }

  func normalizedResults(_ results: DBMovie.ValuesDict, keysMap: DBMovie.ValuesDict, ignoreValues: StringArray) -> DBMovie.ValuesDict {
    var normalizedResults = DBMovie.ValuesDict()
    results.forEach { key, value in
      guard !ignoreValues.contains(value) else { return }
      guard let normalizedKey = keysMap[key] else { return }
      normalizedResults[normalizedKey] = value
    }
    return normalizedResults
  }
}
