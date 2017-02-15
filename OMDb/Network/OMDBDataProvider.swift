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

  private var lastLoadedSearchPage = 0
  private var searchText = ""

  private var requestDisposable: Disposable?
  private let disposeBag = DisposeBag()

  func searchMovie(title: String, completion: @escaping NetworkDataProvider.SearchHandler) {
    searchText = title
    lastLoadedSearchPage = 0
    loadNextSearchPageIfAny(completion: completion)
  }

  func loadNextSearchPageIfAny(completion: @escaping NetworkDataProvider.SearchHandler) {
    let url = Request.search(searchText, lastLoadedSearchPage + 1).url()
    load(url: url) { [weak self] response in
      guard let s = self else { return }
      s.lastLoadedSearchPage += 1
      guard let responseDict = response as? [String: Any] else { return }
      guard let responseValid = responseDict["Response"] as? String, responseValid == "True" else { return }
      guard let totalResults = responseDict["totalResults"] as? String, let totalItems = Int(totalResults) else { return }
      guard let searchResults = responseDict["Search"] as? NSArray as? [DBMovie.ValuesDict] else { return }

      let normSearchResults = searchResults.map { s.normalizedResults($0) }

      completion(normSearchResults, totalItems)
    }
  }

  func loadMovieInfo(imdbID: String, completion: @escaping NetworkDataProvider.InfoHandler) {
    let url = Request.info(imdbID).url()
    load(url: url) { [weak self] response in
      guard let s = self else { return }
      guard let responseDict = response as? DBMovie.ValuesDict else { return }

      let normResponse = s.normalizedResults(responseDict)
      completion(normResponse)
    }
  }

  private func normalizedResults(_ results: DBMovie.ValuesDict) -> DBMovie.ValuesDict {
    return normalizedResults(results, keysMap: OMDBDataProvider.omdbKeysMap, ignoreValues: OMDBDataProvider.ignoreValues)
  }

  private func load(url: URL, onResponse: @escaping (Any) -> Void) {
    print(url)
    requestDisposable?.dispose()
    requestDisposable = json(.get, url)
      .subscribe(onNext: onResponse,
                 onError: { [weak self] error in
                  self?.errorHandler(error)
                })
    requestDisposable!.addDisposableTo(disposeBag)
  }
}
