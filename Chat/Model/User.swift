//
//  User.swift
//  Chat
//
//  Created by David Kababyan on 03/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

struct User: Codable, Equatable {
    var id = ""
    var username: String
    var email: String
    var pushId: String = ""
    var avatarLink: String = ""
    var status: String
    
    static var currentId: String {
        return Auth.auth().currentUser!.uid
    }
    
    static var currentUser: User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.data(forKey: kCURRENTUSER) {

                let decoder = JSONDecoder()
                do {
                    let object = try decoder.decode(User.self, from: dictionary)
                    return object
                } catch {
                    print("error decoding user from userDefaults. ", error.localizedDescription)
                }
            }
        }
        return nil
    }
    
    //for Equatable
    static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id
    }

}

func saveUserLocally(_ user: User) {
    
    let encoder = JSONEncoder()
    do {
        let data = try encoder.encode(user)
        userDefaults.set(data, forKey: kCURRENTUSER)

    } catch {
        print("error saving user locally, ", error.localizedDescription)
    }
}


//needed only to populate with dummy
func createUsers() {
    
    let names = ["Alison Stamp", "Inayah Duggan", "Alfie Thornton", "Rachelle Neale", "Anya Gates", "Juanita Bate"]
    var ImageIndex = 1
    var UserIndex = 1

    for i in 0..<5 {

        let id = UUID().uuidString
        
        let fileDirectory = "Avatars/" + "_\(id)" + ".jpg"

        FileStorage.uploadImage(UIImage(named: "user\(ImageIndex)")!, directory: fileDirectory) { (avatarLink) in
            
            let user = User(id: id, username: names[i], email: "user\(UserIndex)@mail.com", pushId: "", avatarLink: avatarLink ?? "", status: "No Status")
                
            UserIndex += 1
            FirebaseUserListener.shared.saveUserToFireStore(user)
        }

        ImageIndex += 1
        if ImageIndex == 5 {
            ImageIndex = 1
        }
    }
}
