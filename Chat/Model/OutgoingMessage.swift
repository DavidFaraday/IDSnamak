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
    class func send(chatId: String, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?, memberIds: [String]) {

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
        
        if video != nil {
            sendVideoMessage(message: message, video: video!, memberIds: memberIds)
        }
        
        if location != nil {
            sendLocationMessage(message: message, memberIds: memberIds)
        }
        
        if audio != nil {
            sendAudioMessage(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: memberIds)
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
    
    class func sendChannel(channel: Channel, text: String?, photo: UIImage?, video: Video?, audio: String?, audioDuration: Float = 0.0, location: String?) {
        
        let currentUser = User.currentUser()!
        
        let message = LocalMessage()
        message.id = UUID().uuidString
        message.chatRoomId = channel.id
        message.senderId = currentUser.id
        message.senderName = currentUser.username
        
        message.date = Date()
        message.senderInitials = String(currentUser.username.first!)
        message.status = kSENT
        
        
        if text != nil {
            sendTextMessage(message: message, text: text!, memberIds: channel.memberIds, channel: channel)
        }
        
        if photo != nil {
            sendPictureMessage(message: message, photo: photo!, memberIds: channel.memberIds, channel: channel)
        }
        
        if video != nil {
            sendVideoMessage(message: message, video: video!, memberIds: channel.memberIds, channel: channel)
        }
        
        if location != nil {
            sendLocationMessage(message: message, memberIds: channel.memberIds, channel: channel)
        }
        
        if audio != nil {
            sendAudioMessage(message: message, audioFileName: audio!, audioDuration: audioDuration, memberIds: channel.memberIds, channel: channel)
        }
        
        PushNotificationService.shared.sendPushNotificationTo(userIds: removerCurrentUserFrom(userIds: channel.memberIds) , body: message.message, channel: channel)
        
        channel.editChannel(withValues: [kDATE : Date()])
    }
    
    func sendChannelMessage(message: LocalMessage, channel: Channel) {
        
        RealmManager.shared.saveToRealm(message)
        
        FirebaseReference(.Messages).document(channel.id).collection(channel.id).document(message.id).setData(messageDictionary)
    }


    class func updateMessage(withId: String, chatRoomId: String, memberIds: [String]) {
        
        let values = [kSTATUS : kREAD, kREADDATE : Date()] as [String : Any]
        
        for userId in memberIds {
           
            FirebaseReference(.Messages).document(userId).collection(chatRoomId).document(withId).updateData(values)
        }
    }
    
}


func sendTextMessage(message: LocalMessage, text: String, memberIds: [String], channel: Channel? = nil) {
    
    message.message = text
    message.type = kTEXT
    
    let outgoingMessage = OutgoingMessage(message: message, memberIds: memberIds)
    
    if channel != nil {
        outgoingMessage.sendChannelMessage(message: message, channel: channel!)
    } else {
        outgoingMessage.sendMessage(message: message, memberIds: memberIds)
    }
}


func sendPictureMessage(message: LocalMessage, photo: UIImage, memberIds: [String], channel: Channel? = nil) {

    message.message = "Picture message"
    message.type = kPICTURE
    
    
    let fileName = Date().stringDate()
    let fileDirectory = "MediaMessages/Photo/" + "\(message.chatRoomId)/" + "_" + fileName + ".jpg"

    FileStorage.saveFileLocally(fileData: photo.jpegData(compressionQuality: 0.6)! as NSData, fileName: fileName)

    FileStorage.uploadImage(photo, directory: fileDirectory) { (imageURL) in

        if imageURL != nil {
            message.pictureUrl = imageURL ?? ""
            let outgoingMessage = OutgoingMessage(pictureMessage: message, memberIds: memberIds)

            if channel != nil {
                outgoingMessage.sendChannelMessage(message: message, channel: channel!)
            } else {
                outgoingMessage.sendMessage(message: message, memberIds: memberIds)
            }
            
        }
    }
}


func sendVideoMessage(message: LocalMessage, video: Video, memberIds: [String], channel: Channel? = nil) {
    
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
                        
                        if channel != nil {
                            outgoingMessage.sendChannelMessage(message: message, channel: channel!)
                        } else {
                            outgoingMessage.sendMessage(message: message, memberIds: memberIds)
                        }
                        
                    }
                }
            } //End of Uploads
            
            
        } else {
            print("path is nil")
        }
    }
}


func sendLocationMessage(message: LocalMessage, memberIds: [String], channel: Channel? = nil) {
    
    let currentLocation = LocationManager.shared.currentLocation
    message.message = "Location message"
    message.type = kLOCATION
    message.latitude = currentLocation?.latitude ?? 0.0
    message.longitude = currentLocation?.longitude ?? 0.0
    
    let outgoingMessage = OutgoingMessage(message: message, memberIds: memberIds)
    
    if channel != nil {
        outgoingMessage.sendChannelMessage(message: message, channel: channel!)
    } else {
        outgoingMessage.sendMessage(message: message, memberIds: memberIds)
    }
    
}


func sendAudioMessage(message: LocalMessage, audioFileName: String, audioDuration: Float = 0.0, memberIds: [String], channel: Channel? = nil) {

    message.message = "Audio message"
    message.type = kAUDIO
    
    let fileDirectory = "MediaMessages/Audio/" + "\(message.chatRoomId)/" + "_" + audioFileName + ".m4a"

    FileStorage.uploadAudio(audioFileName: audioFileName, directory: fileDirectory) { (audioUrl) in
        
        if audioUrl != nil {
            message.audioUrl = audioUrl ?? ""
            message.audioDuration = Double(audioDuration)
            let outgoingMessage = OutgoingMessage(message: message, memberIds: memberIds)
            
            if channel != nil {
                outgoingMessage.sendChannelMessage(message: message, channel: channel!)
            } else {
                outgoingMessage.sendMessage(message: message, memberIds: memberIds)
            }
        }

    }

}
