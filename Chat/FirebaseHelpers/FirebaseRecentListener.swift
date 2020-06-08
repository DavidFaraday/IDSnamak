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

    func downloadRecentChatsFromFireStore(completion: @escaping (_ allRecents: [RecentChat]) -> Void) {
        
        FirebaseReference(.Recent).whereField(kSENDERID, isEqualTo: User.currentId()).addSnapshotListener() { (querySnapshot, error) in
        
            var recentChats: [RecentChat] = []

            guard let snapshot = querySnapshot else { return }
            
            if !snapshot.isEmpty {

                for recentDocument in snapshot.documents {

                    if recentDocument[kLASTMESSAGE] as! String != "" && recentDocument[kCHATROOMID] != nil && recentDocument[kID] != nil {
                        
                        let recent = RecentChat(recentDocument.data())
                        recentChats.append(recent)
                        
                    }
                }

                recentChats.sort(by: { $0.date > $1.date })
                completion(recentChats)
            } else {
                completion(recentChats)
            }
        }
    }
    
    func updateRecents(chatRoomId: String, lastMessage: String) {

        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                for recent in snapshot.documents {
                    
                    let recentChat = RecentChat(recent.data() )
                    
                    self.updateRecentItem(recent: recentChat, lastMessage: lastMessage)
                }
            }
        }
    }


    private func updateRecentItem(recent: RecentChat, lastMessage: String) {
            
        if recent.senderId != User.currentId() {
            recent.unreadCounter += 1
        }
        
        let values = [kLASTMESSAGE : lastMessage, kUNREADCOUNTER : recent.unreadCounter, kDATE : Date()] as [String : Any]
        
        FirebaseReference(.Recent).document(recent.id).updateData(values)
    }
    
    
    func resetRecentCounter(chatRoomId: String) {
        
        FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).whereField(kSENDERID, isEqualTo: User.currentId()).getDocuments { (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                if let recentData = snapshot.documents.first?.data() {
                    let recent = RecentChat(recentData)
                    self.clearUnreadCounter(recent: recent)
                }
            }
        }
    }


    func clearUnreadCounter(recent: RecentChat) {
        
        let values = [kUNREADCOUNTER : 0] as [String : Any]
        
        FirebaseReference(.Recent).document(recent.id).updateData(values)
    }
}
