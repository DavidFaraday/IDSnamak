//
//  MessageCellDelegate.swift
//  Chat
//
//  Created by David Kababyan on 09/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import MessageKit
import AVFoundation
import AVKit
import SKPhotoBrowser

extension ChatViewController: MessageCellDelegate {

    func didTapImage(in cell: MessageCollectionViewCell) {

        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkmessage = mkmessages[indexPath.section]

            if mkmessage.photoItem != nil && mkmessage.photoItem!.image != nil {
                
                var images = [SKPhoto]()
                let photo = SKPhoto.photoWithImage(mkmessage.photoItem!.image!)
                images.append(photo)

                let browser = SKPhotoBrowser(photos: images)
                browser.initializePageIndex(0)
                present(browser, animated: true, completion: {})
            }

            
            if mkmessage.videoItem != nil && mkmessage.videoItem!.url != nil {
                
                let player = AVPlayer(url: mkmessage.videoItem!.url!)
                let moviewPlayer = AVPlayerViewController()
                
                let session = AVAudioSession.sharedInstance()
                
                try! session.setCategory(.playAndRecord, mode: .default, options: .defaultToSpeaker)
                
                moviewPlayer.player = player
                
                self.present(moviewPlayer, animated: true) {
                    moviewPlayer.player!.play()
                }

            }
        }
    }
}
