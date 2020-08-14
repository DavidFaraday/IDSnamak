//
//  FirebaseRecentListener.swift
//  Chat
//
//  Created by David Kababyan on 06/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import Firebase

class FirebaseRecentListener {
    
    static let shared = FirebaseRecentListener()
    
    private init() {}

    /// Starts listening for recents from FIrebase for current user, returns recents
    ///
    /// - Parameters:
    ///   - callback: All up to date recents of current user.
    func downloadRecentChatsFromFireStore(completion: @escaping (_ allRecents: [RecentChat]) -> Void) {
        
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: User.currentId).addSnapshotListener() { (querySnapshot, error) in
        
            var recentChats: [RecentChat] = []

            guard let documents = querySnapshot?.documents else {
                print("no document for recent chats")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in

                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            for recent in allRecents {
                if recent.lastMessage != "" {
                    recentChats.append(recent)
                }
            }
            
            recentChats.sort(by: { $0.date! > $1.date! })
            completion(recentChats)
        }
    }
    
    /// Updates recentObjects of the chat with given last message
    ///
    /// - Parameters:
    ///   - chatRoomId: The `Id` of chatroom.
    ///   - lastMessage: The `lastMessage` sent.
    func updateRecents(chatRoomId: String, lastMessage: String) {

        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no document for recent update")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }

            for recentChat in allRecents {
                self.updateRecentItemWithNewMessage(recent: recentChat, lastMessage: lastMessage)
            }
        }
    }
    

    /// Resets the counter of the recent object that belongs to current user in specific chatroom
    ///
    /// - Parameters:
    ///   - chatRoomId: The `Id` of chatroom where user is member.
    func resetRecentCounter(chatRoomId: String) {
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentId).getDocuments { (querySnapshot, error) in
            
            guard let documents = querySnapshot?.documents else {
                print("no document for recent counter")
                return
            }
            
            let allRecents = documents.compactMap { (queryDocumentSnapshot) -> RecentChat? in
                return try? queryDocumentSnapshot.data(as: RecentChat.self)
            }
            
            if allRecents.count > 0 {
                self.clearUnreadCounter(recent: allRecents.first!)
            }
        }
    }

    /// The function resents the counter of specific recent object
    ///
    /// - Parameters:
    ///   - recent: The `RecentChat` to reset counter for.

    func clearUnreadCounter(recent: RecentChat) {
        
        var recent = recent
        recent.unreadCounter = 0
        
        self.updateRecent(recent)
    }
    
    /// Updates specific RecentObject with given last message, increments unread for other member
    ///
    /// - Parameters:
    ///   - recent: The `Recent` Recent to update.
    ///   - lastMessage: The `lastMessage` sent.
    private func updateRecentItemWithNewMessage(recent: RecentChat, lastMessage: String) {
            
        var recent = recent
        
        if recent.senderId != User.currentId {
            recent.unreadCounter += 1
        }
        
        recent.lastMessage = lastMessage
        recent.date = Date()
        
        self.updateRecent(recent)
    }

    
    //MARK: - Add Update Delete
    /// Saves Specific Recent Object to firebase
    ///
    /// - Parameters:
    ///   - recent: The `Recent` Recent Object.
    func addRecent(_ recent: RecentChat) {
        
        do {
            let _ = try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }
        catch {
            print(error.localizedDescription, "adding recent....")
        }
    }

    /// Updates Specific Recent Object in firebase
    ///
    /// - Parameters:
    ///   - recent: The `Recent` Recent Object.
    func updateRecent(_ recent: RecentChat) {
        
        do {
            let _ = try FirebaseReference(.Recent).document(recent.id).setData(from: recent)
        }
        catch {
            print(error.localizedDescription, "updating recent....")
        }
        
    }

    /// Deletes Specific Recent Object from firebase
    ///
    /// - Parameters:
    ///   - recent: The `Recent` Recent Object.
    func deleteRecent(_ recent: RecentChat) {
        FirebaseReference(.Recent).document(recent.id).delete()
    }

}
