//
//  IncomingMessage.swift
//  Chat
//
//  Created by David Kababyan on 12/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import MessageKit
//import Firebase

class IncomingMessage {
    
    var messagesCollectionView: MessagesViewController
    
    
    init(collectionView_: MessagesViewController) {
        messagesCollectionView = collectionView_
    }
    
    
    //MARK: CreateMessage
    
    func createMessage(localMessage: LocalMessage) -> MKMessage? {

        let mkMessage = MKMessage(message: localMessage)
//
//        if message.type == kPICTURE {
//
//            let photoItem = PhotoMessage(width: message.photoWidth, height: message.photoHeight)
//
//            mkMessage.photoItem = photoItem
//            mkMessage.kind = MessageKind.photo(photoItem)
//
//            FileStorage.downloadImage(imageUrl: messageDictionary[kMEDIAURL] as? String ?? "") { (image) in
//
//                mkMessage.photoItem?.image = image
//                self.messagesCollectionView.messagesCollectionView.reloadData()
//            }
//        }
        

        return mkMessage
    }

//    //MARK: Helper
//
//    func returnOutgoingStatusForUser(senderId: String) -> Bool {
//
//        return senderId == FUser.currentId()
//    }


}
