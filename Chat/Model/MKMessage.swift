//
//  MKMessage.swift
//  Chat
//
//  Created by David Kababyan on 12/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import MessageKit
import CoreLocation

class MKMessage: NSObject, MessageType {
    
    var messageId: String
    var kind: MessageKind
    var sentDate: Date
    var incoming: Bool
    var mksender: MKSender
    var sender: SenderType { return mksender }
    var senderInitials: String

    var photoItem: PhotoMessage?
    var videoItem: VideoMessage?
    var locationItem: LocationMessage?

    var status: String
    var readDate: Date
    
    init(message: LocalMessage) {

        self.messageId = message.id

        self.mksender = MKSender(senderId: message.senderId, displayName: message.senderName)
        self.status = message.status

        switch message.type {
        case kTEXT:
            self.kind = MessageKind.text(message.message)
            
        case kPICTURE:
            
            let photoItem = PhotoMessage(path: message.pictureUrl)
            
            self.kind = MessageKind.photo(photoItem)
            self.photoItem = photoItem
            
        case kVIDEO:
            let videoItem = VideoMessage(url: nil)
            
            self.kind = MessageKind.video(videoItem)
            self.videoItem = videoItem
            
        case kLOCATION:
            let locationItem = LocationMessage(location: CLLocation(latitude: message.latitude, longitude: message.longitude))
            self.kind = MessageKind.location(locationItem)
            self.locationItem = locationItem

        default:
            self.kind = MessageKind.text(message.message)
        }
        

        self.senderInitials = message.senderInitials
        self.sentDate = message.date
        self.readDate = message.readDate
        self.incoming = User.currentId() != mksender.senderId
    }
}
