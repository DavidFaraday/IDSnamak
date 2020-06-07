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
                    let user = User(id: authDataResult!.user.uid, userName: "User", email: email, pushId: "", avatarLink: "")
                                            
                    user.saveUserLocally()
                    user.saveUserToFireStore()
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
    
    //MARK: - Download 

    func downloadUserFromFirebase(userId: String, email: String? = nil) {
        
        FirebaseReference(.User).document(userId).getDocument { (snapshot, error) in
            guard let snapshot = snapshot else {  return }
            
            if snapshot.exists {

                let user = User(dictionary: snapshot.data()!)
                user.saveUserLocally()
            }
        }
    }

    
    //MARK: - Update
    
    func updateUserInFireStore(withValues : [String : Any], completion: @escaping (_ error: Error?) -> Void) {
        
        if let dictionary = userDefaults.object(forKey: kCURRENTUSER) {
            
            //get user object from userDefaults and update its values
            let userObject = (dictionary as! NSDictionary).mutableCopy() as! NSMutableDictionary
            userObject.setValuesForKeys(withValues)
            
            FirebaseReference(.User).document(User.currentId()).updateData(withValues) { (error) in
                
                completion(error)
                if error == nil {
                    User(dictionary: userObject as! [String : Any]).saveUserLocally()
                } else {
                    print("error updating user, ", error!.localizedDescription)
                }
            }
        }
    }


}
