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
    message.picture = messageDictionary[kPICTURE] as? String ?? ""
    message.video = messageDictionary[kVIDEO] as? String ?? ""
    message.audio = messageDictionary[kAUDIO] as? String ?? ""
    message.width = messageDictionary[kWIDTH] as? Double ?? 0.0
    message.height = messageDictionary[kHEIGHT] as? Double ?? 0.0
    message.latitude = messageDictionary[kLATITUDE] as? Double ?? 0.0
    message.longitude = messageDictionary[kLONGITUDE] as? Double ?? 0.0

    RealmManager.shared.saveToRealm(message)
}
