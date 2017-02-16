//
//  Network.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 14.02.17.
//
//

import Foundation

final class Network {
  typealias SearchHandler = NetworkDataProvider.SearchHandler
  typealias InfoHandler = NetworkDataProvider.InfoHandler
  typealias ErrorHandler = NetworkDataProvider.ErrorHandler

  private static let instance = Network(provider: OMDBDataProvider())

  private let provider: NetworkDataProvider

  private init(provider: NetworkDataProvider) {
    self.provider = provider
  }

  static func loadSearchPage(title: String, page: Int, onComplete: @escaping SearchHandler, onError: @escaping ErrorHandler) {
    if connected() {
      instance.provider.loadSearchPage(title: title, page: page, onComplete: onComplete, onError: onError)
    } else {
      onError(NetworkError.noConnection)
    }
  }

  static func loadMovieInfo(imdbID: String, onComplete: @escaping InfoHandler, onError: @escaping ErrorHandler) {
    if connected() {
      instance.provider.loadMovieInfo(imdbID: imdbID, onComplete: onComplete, onError: onError)
    } else {
      onError(NetworkError.noConnection)
    }
  }
}
