//
//  FirebaseListener.swift
//  Chat
//
//  Created by David Kababyan on 04/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import Firebase

class FirebaseUserListener {
    
    static let shared = FirebaseUserListener()
    
    private init() {}

    //MARK: - Login
    func loginUserWith(email: String, password: String, completion: @escaping (_ error: Error?, _ isEmailVerified: Bool) -> Void) {

        Auth.auth().signIn(withEmail: email, password: password) { (authDataResult, error) in

            if error == nil && authDataResult!.user.isEmailVerified {

                FirebaseUserListener.shared.downloadUserFromFirebase(userId: authDataResult!.user.uid, email: email)

                completion(error, true)
            } else {
                print("Email is not verified")
                completion(error, false)
            }
        }
    }

    //MARK: - Register
    func registerUserWith(email: String, password: String, completion: @escaping (_ error: Error?) -> Void ) {

        Auth.auth().createUser(withEmail: email, password: password, completion: { (authDataResult, error) in

            completion(error)

            if error == nil {

                //send verification email
                authDataResult!.user.sendEmailVerification(completion: { (error) in
                    print("auth email sent error is :", error?.localizedDescription)
                })

                //create user and save it
                if authDataResult?.user != nil {
                    let user = User(id: authDataResult!.user.uid, username: email, email: email, pushId: "", avatarLink: "", status: "Hey there, I'm using Chat!")

                    saveUserLocally(user)
                    self.saveUserToFireStore(user)
                }
            }
        })
    }

    //MARK: - Resend link methods
    func resendVerificationEmail(email: String, completion: @escaping (_ error: Error?) -> Void ) {

        Auth.auth().currentUser?.reload(completion: { (error) in

            Auth.auth().currentUser?.sendEmailVerification(completion: { (error) in

                completion(error)
            })
        })
    }

    func resetPasswordFor(email: String, completion: @escaping (_ error: Error?) -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            completion(error)
        }
    }

    func logOutCurrentUser(completion: @escaping (_ error: Error?) -> Void) {

        do {
            try Auth.auth().signOut()

            userDefaults.removeObject(forKey: kCURRENTUSER)
            userDefaults.synchronize()
            completion(nil)

        } catch let error as NSError {
            completion(error)
        }
    }

    
    //MARK: - Download
    func downloadUserFromFirebase(userId: String, email: String? = nil) {

        FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in

            guard let document = querySnapshot else {
                print("no document for user")
                return
            }

            let result = Result {
                try? document.data(as: User.self)
            }

            switch result {
            case .success(let userObject):
                
                if let user = userObject {
                    saveUserLocally(user)
                }
            case .failure(let error):
                // A `City` value could not be initialized from the DocumentSnapshot.
                print("Error decoding city: \(error)")
            }
        }
    }

    func downloadAllUsersFromFirebase(completion: @escaping (_ allUsers: [User]) -> Void) {

        var users:[User] = []

        FirebaseReference(.User).limit(to: 500).getDocuments { (querySnapshot, error) in

            guard let documents = querySnapshot?.documents else {
                print("no document for all users")
                return
            }

            let allUsers = documents.compactMap { (queryDocumentSnapshot) -> User? in
                return try? queryDocumentSnapshot.data(as: User.self)
            }


            for user in allUsers {
                //don't add current users
                if User.currentId != user.id {
                    users.append(user)
                }
            }

            completion(users)
        }
    }
    
    func downloadUserFromFirebase(withIds: [String], completion: @escaping (_ users: [User]) -> Void ) {

        var count = 0
        var usersArray: [User] = []

        //go through each user and download it from firestore
        for userId in withIds {

            FirebaseReference(.User).document(userId).getDocument { (querySnapshot, error) in

                guard let document = querySnapshot else {
                    print("no document for user per id")
                    completion(usersArray)
                    return
                }

                let user = try? document.data(as: User.self)
                //TODO: check if ok

                usersArray.append(user!)
                count += 1

                if count == withIds.count {
                    completion(usersArray)
                }
            }
        }
    }


    //MARK: - Saving user
    func saveUserToFireStore(_ user: User) {
        do {
            let _ = try FirebaseReference(.User).document(user.id).setData(from: user)
        }
        catch {
          print(error.localizedDescription, "adding user....")
        }
    }

}
