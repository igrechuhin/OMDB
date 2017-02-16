//
//  OMDBDataProvider.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 14.02.17.
//
//

import RxAlamofire
import RxSwift

final class OMDBDataProvider: NetworkDataProvider {
  private enum Request {
    case search(String, Int)
    case info(String)

    private func parameters() -> String {
      switch self {
      case .search(let searchText, let page): return "s=\(searchText)&page=\(page)"
      case .info(let imdbID): return "i=\(imdbID)"
      }
    }

    func url() -> URL {
      let baseURL = "http://www.omdbapi.com/?"
      return URL(string: baseURL + parameters())!
    }
  }

  private static let omdbKeysMap = ["Title": "title",
                                    "Year": "year",
                                    "Rated": "rated",
                                    "Released": "released",
                                    "Runtime": "runtime",
                                    "Genre": "genre",
                                    "Director": "director",
                                    "Writer": "writer",
                                    "Actors": "actors",
                                    "Plot": "plot",
                                    "Language": "language",
                                    "Country": "country",
                                    "Awards": "awards",
                                    "Poster": "poster",
                                    "Metascore": "metascore",
                                    "imdbRating": "imdbRating",
                                    "imdbVotes": "imdbVotes",
                                    "imdbID": "imdbID",
                                    "Type": "type"]
  private static let ignoreValues = ["N/A"]

  private var requestDisposable: Disposable? {
    willSet { requestDisposable?.dispose() }
    didSet { requestDisposable?.addDisposableTo(disposeBag) }
  }

  private let disposeBag = DisposeBag()

  func loadSearchPage(title: String,
                      page: Int,
                      onComplete: @escaping NetworkDataProvider.SearchHandler,
                      onError: @escaping NetworkDataProvider.ErrorHandler) {
    let url = Request.search(title, page).url()
    load(url: url, onResponse: { [weak self] response in
      guard let s = self else { return }
      guard let responseDict = response as? [String: Any] else {
        onError(NetworkError.invalidResponse)
        return
      }
      guard let responseValid = responseDict["Response"] as? String, responseValid == "True" else {
        onError(NetworkError.invalidResponse)
        return
      }
      guard let totalResults = responseDict["totalResults"] as? String, let totalItems = Int(totalResults) else {
        onError(NetworkError.invalidResponse)
        return
      }
      guard let searchResults = responseDict["Search"] as? NSArray as? [DBMovie.ValuesDict] else {
        onError(NetworkError.invalidResponse)
        return
      }

      let normSearchResults = searchResults.map { s.normalizedResults($0) }
      onComplete(normSearchResults, totalItems)
    }, onError: onError)
  }

  func loadMovieInfo(imdbID: String,
                     onComplete: @escaping NetworkDataProvider.InfoHandler,
                     onError: @escaping NetworkDataProvider.ErrorHandler) {
    let url = Request.info(imdbID).url()
    load(url: url, onResponse: { [weak self] response in
      guard let s = self else { return }
      guard let responseDict = response as? DBMovie.ValuesDict else {
        onError(NetworkError.invalidResponse)
        return
      }

      let normResponse = s.normalizedResults(responseDict)
      onComplete(normResponse)
    }, onError: onError)
  }

  private func normalizedResults(_ results: DBMovie.ValuesDict) -> DBMovie.ValuesDict {
    return normalizedResults(results, keysMap: OMDBDataProvider.omdbKeysMap, ignoreValues: OMDBDataProvider.ignoreValues)
  }

  private func load(url: URL, onResponse: @escaping (Any) -> Void, onError: @escaping NetworkDataProvider.ErrorHandler) {
    requestDisposable = json(.get, url).subscribe(onNext: onResponse, onError: { error in
      onError(NetworkError.other(error))
    })
  }
}
