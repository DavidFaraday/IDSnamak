//
//  User.swift
//  Chat
//
//  Created by David Kababyan on 03/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import Firebase

class User {
    
    var id: String
    var username: String
    var email: String
    var pushId: String = ""
    var avatarLink: String = ""
    var status: String
    
    init(id: String, userName: String, email: String, pushId: String, avatarLink: String) {
        
        self.id = id
        self.username = userName
        self.email = email
        self.pushId = pushId
        self.avatarLink = avatarLink
        self.status = ""
    }
    
    init(dictionary: [String : Any]) {
        
        id = dictionary[kID] as? String ?? ""
        email = dictionary[kEMAIL] as? String ?? ""
        username = dictionary[kUSERNAME] as? String ?? ""
        pushId = dictionary[kPUSHID] as? String ?? ""
        avatarLink = dictionary[kAVATARLINK] as? String ?? ""
        status = dictionary[kSTATUS] as? String ?? ""

    }
    
    
    var dictionary : [String : Any] {
        return [kID : id, kUSERNAME: username, kEMAIL : email, kPUSHID : pushId, kAVATARLINK: avatarLink, kSTATUS: status]
    }
    
    class func currentId() -> String {
        return Auth.auth().currentUser!.uid
    }

    class func currentUser () -> User? {
        if Auth.auth().currentUser != nil {
            if let dictionary = UserDefaults.standard.object(forKey: kCURRENTUSER) {
                return User.init(dictionary: dictionary as! [String : Any])
            }
        }
        return nil
    }

    
    func saveUserLocally() {
        userDefaults.set(self.dictionary, forKey: kCURRENTUSER)
        userDefaults.synchronize()
    }
    
    func saveUserToFireStore() {

        FirebaseReference(.User).document(self.id).setData(self.dictionary) { (error) in
            if error != nil {
                print("error saving user \(error!.localizedDescription)")
            }
        }
    }

    //MARK: - LogOut
    class func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {

        do {
            try Auth.auth().signOut()
            
            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)
            
        } catch let error as NSError {
            completion(error)
        }
    }

}


//needed only to populate with dummy
func createUsers() {
    
    let names = ["Alison Stamp", "Inayah Duggan", "Alfie Thornton", "Rachelle Neale", "Anya Gates", "Juanita Bate"]
    var ImageIndex = 1
    var UserIndex = 1

    for _ in 0..<5 {

        let id = UUID().uuidString
        let randomNumber = Int.random(in: 0 ... 5)
        
        let fileDirectory = "Avatars/" + "\(id)" + ".jpg"

        FileStorage.uploadImage(UIImage(named: "user\(ImageIndex)")!, directory: fileDirectory) { (avatarLink) in
            
            let user = User(id: id, userName: names[randomNumber], email: "user\(UserIndex)@mail.com", pushId: "", avatarLink: avatarLink ?? "")
                
            UserIndex += 1
            user.saveUserToFireStore()
        }

        ImageIndex += 1
        if ImageIndex == 5 {
            ImageIndex = 1
        }
    }
}
