//
//  Network.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 14.02.17.
//
//

import Foundation

final class Network {
  typealias ConnectionBlock = () -> Void

  private static let instance = Network(provider: OMDBDataProvider())

  private let provider: NetworkDataProvider

  private init(provider: NetworkDataProvider) {
    self.provider = provider
  }

  static func searchMovie(title: String, completion: @escaping NetworkDataProvider.SearchHandler, noConnection: ConnectionBlock) {
    checkConnectionAndPerform(onHasConnection: {
      instance.provider.searchMovie(title: title, completion: completion)
    }, onNoConnection: noConnection)
  }

  static func loadNextSearchPageIfAny(completion: @escaping NetworkDataProvider.SearchHandler, noConnection: ConnectionBlock) {
  checkConnectionAndPerform(onHasConnection: { 
    instance.provider.loadNextSearchPageIfAny(completion: completion)
  }, onNoConnection: noConnection)

  }

  static func loadMovieInfo(imdbID: String, completion: @escaping NetworkDataProvider.InfoHandler, noConnection: ConnectionBlock) {
    checkConnectionAndPerform(onHasConnection: { 
      instance.provider.loadMovieInfo(imdbID: imdbID, completion: completion)
    }, onNoConnection: noConnection)
  }

  private static func checkConnectionAndPerform(onHasConnection: ConnectionBlock, onNoConnection: ConnectionBlock) {
    if connected() {
      onHasConnection()
    } else {
      onNoConnection()
    }
  }
}
