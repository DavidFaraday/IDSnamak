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

        if localMessage.type == kPICTURE {

            let photoItem = PhotoMessage(path: localMessage.pictureUrl)

            mkMessage.photoItem = photoItem
            mkMessage.kind = MessageKind.photo(photoItem)
            
            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl, isMessage: true) { (image) in

                mkMessage.photoItem?.image = image
                self.messagesCollectionView.messagesCollectionView.reloadData()
            }
        }
        
        if localMessage.type == kVIDEO {

            FileStorage.downloadImage(imageUrl: localMessage.pictureUrl, isMessage: true) { (image) in

                FileStorage.downloadVideo(videoUrl: localMessage.videoUrl) { (readyToPlay, fileName) in
                    
                    let videoURL = URL(fileURLWithPath: fileInDocumentsDirectory(filename: fileName))
                    
                    let videoItem = VideoMessage(url: videoURL)

                    mkMessage.videoItem = videoItem
                    mkMessage.kind = MessageKind.video(videoItem)
                }


                mkMessage.videoItem?.image = image
                self.messagesCollectionView.messagesCollectionView.reloadData()
            }
        }

        

        return mkMessage
    }

}
