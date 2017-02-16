//
//  NetworkDataProvider.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 14.02.17.
//
//

import UIKit

protocol NetworkDataProvider {
  typealias ValuesDict = DBMovie.ValuesDict
  typealias StringArray = [String]
  typealias SearchHandler = ([ValuesDict], Int) -> Void
  typealias InfoHandler = (ValuesDict) -> Void
  typealias ErrorHandler = (NetworkError) -> Void

  func loadSearchPage(title: String, page: Int, onComplete: @escaping SearchHandler, onError: @escaping ErrorHandler)

  func loadMovieInfo(imdbID: String, onComplete: @escaping InfoHandler, onError: @escaping ErrorHandler)
 
  func normalizedResults(_ results: ValuesDict, keysMap: ValuesDict, ignoreValues: StringArray) -> ValuesDict
}

extension NetworkDataProvider {
  func normalizedResults(_ results: ValuesDict, keysMap: ValuesDict, ignoreValues: StringArray) -> ValuesDict {
    var normalizedResults = ValuesDict()
    results.forEach { key, value in
      guard !ignoreValues.contains(value) else { return }
      guard let normalizedKey = keysMap[key] else { return }
      normalizedResults[normalizedKey] = value
    }
    return normalizedResults
  }
}
