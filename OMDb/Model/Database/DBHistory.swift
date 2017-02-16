//
//  DBHistory.swift
//  OMDb
//
//  Created by Ilya Grechuhin on 14.02.17.
//
//

import RealmSwift

final class DBHistory: Object {
  dynamic var text = ""

  override static func primaryKey() -> String? {
    return "text"
  }
}

extension DBHistory {
  static func create(title: String) {
    let realm = try! Realm()
    try! realm.write {
      realm.create(self, value: ["text": title], update: true)
    }
  }

  static func requests() -> Results<DBHistory> {
    let realm = try! Realm()
    return realm.objects(self)
  }
}
