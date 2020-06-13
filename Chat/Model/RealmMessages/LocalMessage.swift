//
//  LocalMessage.swift
//  Chat
//
//  Created by David Kababyan on 12/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import RealmSwift

class LocalMessage: Object {
    
    @objc dynamic var id = ""
    @objc dynamic var chatRoomId = ""
    @objc dynamic var date = Date()
    @objc dynamic var senderName = ""
    @objc dynamic var senderId = ""
    @objc dynamic var senderInitials = ""
    @objc dynamic var readDate = Date()
    @objc dynamic var type = ""
    @objc dynamic var status = ""
    @objc dynamic var message = ""
    @objc dynamic var audio = ""
    @objc dynamic var video = ""
    @objc dynamic var picture = ""
    @objc dynamic var width = 0.0
    @objc dynamic var height = 0.0
    @objc dynamic var latitude = 0.0
    @objc dynamic var longitude = 0.0
    
    override static func primaryKey() -> String? {
        return "id"
    }

    var dictionary: NSDictionary {
        
        return NSDictionary(objects: [self.id,
                                      self.chatRoomId,
                                      self.date,
                                      self.senderName,
                                      self.senderId,
                                      self.senderInitials,
                                      self.readDate,
                                      self.type,
                                      self.status,
                                      self.message,
                                      self.audio,
                                      self.video,
                                      self.picture,
                                      self.width,
                                      self.height,
                                      self.latitude,
                                      self.longitude
                                      
            ],
                            forKeys: [kID as NSCopying,
                                      kCHATROOMID as NSCopying,
                                      kDATE as NSCopying,
                                      kSENDERNAME as NSCopying,
                                      kSENDERID as NSCopying,
                                      kSENDERINITIALS as NSCopying,
                                      kREADDATE as NSCopying,
                                      kTYPE as NSCopying,
                                      kSTATUS as NSCopying,
                                      kMESSAGE as NSCopying,
                                      kAUDIO as NSCopying,
                                      kVIDEO as NSCopying,
                                      kPICTURE as NSCopying,
                                      kWIDTH as NSCopying,
                                      kHEIGHT as NSCopying,
                                      kLATITUDE as NSCopying,
                                      kLONGITUDE as NSCopying
            ]
        )
    }

}


