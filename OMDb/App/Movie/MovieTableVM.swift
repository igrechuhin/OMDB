//
//  MovieTableVM.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 16.02.17.
//
//

import RealmSwift
import RxRealm
import RxSwift

struct MovieTableVM: MovieTableVMProtocol {
  typealias CellModel = MovieTableVMProtocol.CellModel

  var model: DBMovie

  var title: String {
    return model.title
  }

  var posterURL: URL? {
    guard let poster = model.poster else { return nil }
    return URL(string: poster)
  }

  var tableViewModel: Observable<[CellModel]> {
    let tableFields = model.objectSchema.properties.filter { $0.name != "poster" }.map { $0.name }
    return Observable.from(object: model)
      .map { model -> [CellModel] in
        return tableFields
          .filter { model[$0] != nil }
          .map { key -> CellModel in
            return (key: key, value: model[key] as! String)
          }
      }
  }

  func updateInfo() {
    Network.loadMovieInfo(imdbID: model.imdbID,
      onComplete: {
        DBMovie.createOrUpdate(value: $0)
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

  init(model: DBMovie) {
    self.model = model
  }
}
