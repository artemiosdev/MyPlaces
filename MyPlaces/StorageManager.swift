//
//  StorageManager.swift
//  MyPlaces
//
//  Created by Artem Androsenko on 06.12.2022.
//

import Realm
import RealmSwift

// Get the default Realm
let realm = try! Realm()

class StorageManager {
    static func saveObject(_ place: Place) {
        // запись в базу данных
        try! realm.write({
            // данный экземпляр и есть
            // точка входа в базу данных
            realm.add(place)
        })
    }
    static func deleteObject(_ place: Place) {
        try! realm.write({
            realm.delete(place)
        })
    }
}


