//
//  DBMovie.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 11.02.17.
//
//

import RealmSwift

final class DBMovie: Object {
  typealias ValuesDict = [String: String]

  dynamic var title = ""
  dynamic var year = ""
  dynamic var imdbID = ""
  dynamic var type = ""

  dynamic var rated: String?
  dynamic var released: String?
  dynamic var runtime: String?
  dynamic var genre: String?
  dynamic var director: String?
  dynamic var writer: String?
  dynamic var actors: String?
  dynamic var plot: String?
  dynamic var language: String?
  dynamic var country: String?
  dynamic var awards: String?
  dynamic var poster: String?
  dynamic var metascore: String?
  dynamic var imdbRating: String?
  dynamic var imdbVotes: String?
  dynamic var totalSeasons: String?

  override static func indexedProperties() -> [String] {
    return ["title"]
  }

  override static func primaryKey() -> String? {
    return "imdbID"
  }

  static func createOrUpdate(value: ValuesDict) {
    let realm = try! Realm()
    try! realm.write {
      realm.create(self, value: value, update: true)
    }
  }

  static func createOrUpdate(values: [DBMovie.ValuesDict]) {
    let realm = try! Realm()
    try! realm.write {
      values.forEach { realm.create(self, value: $0, update: true) }
    }
  }

  static func moviesWithTitleContaining(_ text: String) -> Results<DBMovie> {
    let realm = try! Realm()
    return realm.objects(self).filter("title contains[c] '\(text)'")
  }
}
