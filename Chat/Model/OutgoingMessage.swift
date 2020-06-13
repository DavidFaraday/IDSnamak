//
//  OutgoingMessage.swift
//  Chat
//
//  Created by David Kababyan on 12/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import UIKit

class OutgoingMessage {
    
    var messageDictionary: [String : Any]
    
    
    //MARK: - Initializer
    //text message
    init (message: LocalMessage, text: String, memberIds: [String]) {

        message.type = kTEXT
        message.message = text

        messageDictionary = message.dictionary as! [String : Any]
    }

//    init (message: LocalMessage, photo: UIImage, photoURL: String, memberIds: [String]) {
//
//        message.type = kPICTURE
//        message.message = "Picture message"
//        message.photoWidth = Int(photo.size.width)
//        message.photoHeight = Int(photo.size.height)
//        message.mediaURL = photoURL
//
//        messageDictionary = message.dictionary as! [String : Any]
//    }

    //MARK: - Send Message
    class func send(chatId: String, text: String?, photo: UIImage?, memberIds: [String]) {

        let currentUser = User.currentUser()!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        
        message.date = Date()
        message.senderInitials = String(currentUser.username.first!)
        message.status = kSENT
        message.message = text ?? "Picture message"
        
        if text != nil {
            let outgoingMessage = OutgoingMessage(message: message, text: text!, memberIds: memberIds)
            outgoingMessage.sendMessage(chatRoomId: chatId, messageId: message.id, memberIds: memberIds)
        } else  {
//            if photo != nil {
//
//                let fileName = Date().stringDate()
//                let fileDirectory = "MediaMessages/Photo/" + "\(chatId)/" + "_" + fileName + ".jpg"
//
//                FileStorage.saveImageLocally(imageData: photo!.jpegData(compressionQuality: 0.6)!, fileName: fileName)
//
//                FileStorage.uploadImage(photo!, directory: fileDirectory) { (imageURL) in
//
//                    if imageURL != nil {
//                        let outgoingMessage = OutgoingMessage(message: message, photo: photo!, photoURL: imageURL!, memberIds: memberIds)
//
//                        outgoingMessage.sendMessage(chatRoomId: chatId, messageId: message.id, memberIds: memberIds)
//
//                    }
//                }
//            }
        }
        
        PushNotificationService.shared.sendPushNotificationTo(userIds: removerCurrentUserFrom(userIds: memberIds) , body: message.message)
        FirebaseRecentListener.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
        
        RealmManager.shared.saveToRealm(message)
    }

    func sendMessage(chatRoomId: String, messageId: String, memberIds: [String]) {
  
        for memberId in memberIds {
            
            FirebaseReference(.Messages).document(memberId).collection(chatRoomId).document(messageId).setData(messageDictionary)
        }
    }

    class func updateMessage(withId: String, chatRoomId: String, memberIds: [String]) {
        
        let values = [kSTATUS : kREAD, kREADDATE : Date()] as [String : Any]
        
        for userId in memberIds {
           
            FirebaseReference(.Messages).document(userId).collection(chatRoomId).document(withId).updateData(values)
        }
    }
    
}
