//
//  NetworkError.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 16.02.17.
//
//

import Foundation

enum NetworkError: Error {
  case noConnection
  case invalidResponse
  case other(Error)
}
