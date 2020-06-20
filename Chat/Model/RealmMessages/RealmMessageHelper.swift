//
//  RealmMessageHelper.swift
//  Chat
//
//  Created by David Kababyan on 12/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import Firebase

func createLocalMessage(messageDictionary: Dictionary<String, Any>)  {
    
    let message = LocalMessage()
    
    message.chatRoomId = messageDictionary[kCHATROOMID] as? String ?? ""
    message.id = messageDictionary[kID] as? String ?? ""
    message.senderId = messageDictionary[kSENDERID] as? String ?? ""
    message.senderName = messageDictionary[kSENDERNAME] as? String ?? ""
    message.senderInitials = messageDictionary[kSENDERINITIALS] as? String ?? ""
    message.date = (messageDictionary[kDATE] as? Timestamp)?.dateValue() ?? Date()
    message.readDate = (messageDictionary[kREADDATE] as? Timestamp)?.dateValue() ?? Date()
    message.status = messageDictionary[kSTATUS] as? String ?? ""
    message.type = messageDictionary[kTYPE] as? String ?? ""
    message.message = messageDictionary[kMESSAGE] as? String ?? ""
    message.pictureUrl = messageDictionary[kPICTUREURL] as? String ?? ""
    message.videoUrl = messageDictionary[kVIDEOURL] as? String ?? ""
    message.audioUrl = messageDictionary[kAUDIOURL] as? String ?? ""
    message.photoWidth = messageDictionary[kPICTUREWIDTH] as? Int ?? 0
    message.photoHeight = messageDictionary[kPICTUREHEIGHT] as? Int ?? 0
    message.latitude = messageDictionary[kLATITUDE] as? Double ?? 0.0
    message.longitude = messageDictionary[kLONGITUDE] as? Double ?? 0.0

    RealmManager.shared.saveToRealm(message)
}
