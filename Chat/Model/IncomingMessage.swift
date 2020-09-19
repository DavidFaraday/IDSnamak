//
//  IncomingMessage.swift
//  Chat
//
//  Created by David Kababyan on 12/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import MessageKit
import CoreLocation

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
//                    self.messagesCollectionView.messagesCollectionView.reloadData()
                }

                mkMessage.videoItem?.image = image
                self.messagesCollectionView.messagesCollectionView.reloadData()
            }
        }

        if localMessage.type == kLOCATION {
            
            let locationItem = LocationMessage(location: CLLocation(latitude: localMessage.latitude, longitude: localMessage.longitude))
            mkMessage.kind = MessageKind.location(locationItem)
            mkMessage.locationItem = locationItem
        }
        
        if localMessage.type == kAUDIO {

            let audioMessage = AudioMessage(duration: Float(localMessage.audioDuration))

            mkMessage.audioItem = audioMessage
            mkMessage.kind = MessageKind.audio(audioMessage)

            FileStorage.downloadAudio(audioUrl: localMessage.audioUrl) { (fileName) in

                let audioURL = URL(fileURLWithPath: fileInDocumentsDirectory(filename: fileName))

                mkMessage.audioItem?.url = audioURL

            }
        //not needed?
//            self.messagesCollectionView.messagesCollectionView.reloadData()

        }

        return mkMessage
    }

}
