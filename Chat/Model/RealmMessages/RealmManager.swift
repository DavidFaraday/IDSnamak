//
//  RealmManager.swift
//  Chat
//
//  Created by David Kababyan on 12/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import RealmSwift

class RealmManager {
    
    static let shared = RealmManager()
    let realm = try! Realm()

    private init() {}

    func saveToRealm<T: Object>(_ object: T) {

        do {
            try realm.write {
                realm.add(object, update: .all)
            }
        } catch {
            print("Error saving realm object \(error.localizedDescription)")
        }
    }

    func deleteFromRealm<T: Object>(_ object: T) {

        do {
            try realm.write {
                realm.delete(object)
            }
        } catch {
            print("Error deleting real object \(error.localizedDescription)")
        }
    }

}
