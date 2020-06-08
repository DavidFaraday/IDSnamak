//
//  StartChat.swift
//  Chat
//
//  Created by David Kababyan on 08/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import Firebase

//MARK: - Starting Chat
func startChat(user1: User, user2: User) -> String {

    let chatRoomId = chatRoomIdFrom(user1Id: user1.id, user2Id: user2.id)
        
    createRecentItems(chatRoomId: chatRoomId, users: [user1, user2])
    
    return chatRoomId
}


//MARK: - RecentChats
func createRecentItems(chatRoomId: String, users: [User]) {
    
    var memberIdsToCreateRecent = [users.first!.id, users.last!.id]
    
    //check if the user has recent with that chatRoom id, if no create one
    FirebaseReference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomId).getDocuments { (snapshot, error) in
        
        guard let snapshot = snapshot else { return }
        
        if !snapshot.isEmpty {
            
            memberIdsToCreateRecent = removeMemberWhoHasRecent(snapshot: snapshot, memberIds: memberIdsToCreateRecent)
        }
        
        //create recents for remaining users
        for userId in memberIdsToCreateRecent {
            
            let senderUser = userId == User.currentId() ? users.first! : users.last!

            let receiverUser = userId == User.currentId() ? users.last! : users.first!
            
            
            let recentObject = RecentChat()
            
            recentObject.id = UUID().uuidString
            recentObject.chatRoomId = chatRoomId
            recentObject.senderId = senderUser.id
            recentObject.senderName = senderUser.username
            recentObject.receiverId = receiverUser.id
            recentObject.receiverName = receiverUser.username
            recentObject.date = Date()
            recentObject.memberIds = [senderUser.id, receiverUser.id]
            recentObject.lastMessage = ""
            recentObject.unreadCounter = 0
            recentObject.avatarLink = receiverUser.avatarLink
            
            recentObject.saveToFirestore()
        }
    }
 
}



func removeMemberWhoHasRecent(snapshot: QuerySnapshot, memberIds: [String]) -> [String] {
    
    var memberIdsToCreateRecent = memberIds

    for recentData in snapshot.documents {
        
        let currentRecent = recentData.data() as Dictionary
        
        //check if recent has userId
        if let currentUserId = currentRecent[kSENDERID] {

            //if the member has recent, remove it from array
            if memberIdsToCreateRecent.contains(currentUserId as! String) {

                memberIdsToCreateRecent.remove(at: memberIdsToCreateRecent.firstIndex(of: currentUserId as! String)!)
            }
        }
    }

    return memberIdsToCreateRecent
}

func chatRoomIdFrom(user1Id: String, user2Id: String) -> String {
    
    var chatRoomId = ""
    
    let value = user1Id.compare(user2Id).rawValue

    chatRoomId = value < 0 ? (user1Id + user2Id) : (user2Id + user1Id)

    return chatRoomId
}
