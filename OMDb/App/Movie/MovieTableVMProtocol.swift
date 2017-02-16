//
//  MovieTableVMProtocol.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 16.02.17.
//
//

import RxSwift

protocol MovieTableVMProtocol {
  typealias CellModel = MovieTableVC.Cell.Model

  var title: String { get }
  var posterURL: URL? { get }
  var tableViewModel: Observable<[CellModel]> { get }

  func updateInfo()
}
