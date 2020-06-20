//
//  OutgoingMessage.swift
//  Chat
//
//  Created by David Kababyan on 12/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import UIKit
import Gallery

class OutgoingMessage {
    
    var messageDictionary: [String : Any]
    
    
    //MARK: - Initializer
    init (message: LocalMessage, memberIds: [String]) {
        messageDictionary = message.dictionary as! [String : Any]
    }

    init (pictureMessage: LocalMessage, memberIds: [String]) {

        pictureMessage.type = kPICTURE
        pictureMessage.message = "Picture message"

        messageDictionary = pictureMessage.dictionary as! [String : Any]
    }
    

    //MARK: - Send Message
    class func send(chatId: String, text: String?, photo: UIImage?, video: Video?, audio: String?, memberIds: [String]) {
        print("send chat")
        let currentUser = User.currentUser()!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = chatId
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        
        message.date = Date()
        message.senderInitials = String(currentUser.username.first!)
        message.status = kSENT
        
        
        if text != nil {
            sendTextMessage(message: message, text: text!, memberIds: memberIds)
        }
        
        if photo != nil {
            sendPictureMessage(message: message, photo: photo!, memberIds: memberIds)
        }
        
        //video
        if video != nil {
            sendVideoMessage(message: message, video: video!, memberIds: memberIds)
        }
        
        
        PushNotificationService.shared.sendPushNotificationTo(userIds: removerCurrentUserFrom(userIds: memberIds) , body: message.message)
        FirebaseRecentListener.shared.updateRecents(chatRoomId: chatId, lastMessage: message.message)
    }

    func sendMessage(message: LocalMessage, memberIds: [String]) {
  
        RealmManager.shared.saveToRealm(message)

        for memberId in memberIds {
            
            FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(messageDictionary)
        }
    }

    class func updateMessage(withId: String, chatRoomId: String, memberIds: [String]) {
        
        let values = [kSTATUS : kREAD, kREADDATE : Date()] as [String : Any]
        
        for userId in memberIds {
           
            FirebaseReference(.Messages).document(userId).collection(chatRoomId).document(withId).updateData(values)
        }
    }
    
}


func sendTextMessage(message: LocalMessage, text: String, memberIds: [String]) {
    
    message.message = text
    message.type = kTEXT
    
    let outgoingMessage = OutgoingMessage(message: message, memberIds: memberIds)
    outgoingMessage.sendMessage(message: message, memberIds: memberIds)
}


func sendPictureMessage(message: LocalMessage, photo: UIImage, memberIds: [String]) {
    
    message.message = "Picture message"
    message.type = kPICTURE
    
    
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_" + fileName + ".jpg"

    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)

    FileStorage.uploadImage(photo, directory: fileDirectory) { (imageURL) in

        if imageURL != nil {
            message.pictureUrl = imageURL ?? ""
            let outgoingMessage = OutgoingMessage(pictureMessage: message, memberIds: memberIds)

            outgoingMessage.sendMessage(message: message, memberIds: memberIds)
        }
    }
}


func sendVideoMessage(message: LocalMessage, video: Video, memberIds: [String]) {
    
    message.message = "Video message"
    message.type = kVIDEO
    
    let fileName = Date().stringDate()
    let thumbnailDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_" + fileName + ".jpg"
    let videoDirectory = "MediaMessages/Video/" + "\(message.chatRoomId)/" + "_" + fileName + ".mov"
    
    
    let editor = VideoEditor()
    editor.process(video: video) { (processedVideo, videoURL) in
        
        if let tempPath = videoURL {
            
            let thumbnail = videoThumbnail(video: tempPath)
            FileStorage.saveFileLocally(fileData: thumbnail.jpegData(compressionQuality: 0.7)! as NSData, fileName: fileName)
            
            //upload thumbnail and video
            FileStorage.uploadImage(thumbnail, directory: thumbnailDirectory, isThumbnail: true) { (imageLink) in

                if imageLink != nil {
                    
                    let videoData = NSData(contentsOfFile: tempPath.path)
                    
                    FileStorage.saveFileLocally(fileData: videoData!, fileName: fileName + ".mov")
                    
                    FileStorage.uploadVideo(video: videoData!, directory: videoDirectory) { (videoLink) in
                        
                        message.pictureUrl = imageLink ?? ""
                        message.videoUrl = videoLink ?? ""
                        
                        let outgoingMessage = OutgoingMessage(message: message, memberIds: memberIds)
                        outgoingMessage.sendMessage(message: message, memberIds: memberIds)
                    }
                }
            } //End of Uploads
            
            
        } else {
            print("path is nil")
        }
    }
}
