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
    
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkmessage = mkmessages[indexPath.section]
            
            if mkmessage.locationItem != nil {
                
                let mapView = MapViewViewController()
                mapView.location = mkmessage.locationItem?.location
                
                navigationController?.pushViewController(mapView, animated: true)
            }
        }
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }

}



//MARK: - Channel

extension ChannelChatViewController: MessageCellDelegate {

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
    
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        
        if let indexPath = messagesCollectionView.indexPath(for: cell) {
            let mkmessage = mkmessages[indexPath.section]
            
            if mkmessage.locationItem != nil {
                
                let mapView = MapViewViewController()
                mapView.location = mkmessage.locationItem?.location
                
                navigationController?.pushViewController(mapView, animated: true)
            }
        }
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        
        guard let indexPath = messagesCollectionView.indexPath(for: cell),
            let message = messagesCollectionView.messagesDataSource?.messageForItem(at: indexPath, in: messagesCollectionView) else {
                print("Failed to identify message when audio cell receive tap gesture")
                return
        }
        guard audioController.state != .stopped else {
            // There is no audio sound playing - prepare to start playing for given audio message
            audioController.playSound(for: message, in: cell)
            return
        }
        if audioController.playingMessage?.messageId == message.messageId {
            // tap occur in the current cell that is playing audio sound
            if audioController.state == .playing {
                audioController.pauseSound(for: message, in: cell)
            } else {
                audioController.resumeSound()
            }
        } else {
            // tap occur in a difference cell that the one is currently playing sound. First stop currently playing and start the sound for given message
            audioController.stopAnyOngoingPlaying()
            audioController.playSound(for: message, in: cell)
        }
    }

}

