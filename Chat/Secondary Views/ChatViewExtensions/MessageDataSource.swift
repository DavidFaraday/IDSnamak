//
//  MessageDataSource.swift
//  Chat
//
//  Created by David Kababyan on 09/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import MessageKit

extension ChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {

        return currentUser
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {

        return mkmessages.count
    }


    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {

        return mkmessages[indexPath.section]
    }

    //MARK: - Cell top label
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        if (indexPath.section % 3 == 0) {

            let showLoadMore = (indexPath.section == 0) && (allLocalMessages.count > displayingMessagesCount)
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        }
        return nil
    }

    //MARK: - Cell Bottom label
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        if (isFromCurrentSender(message: message)) {
            let message = mkmessages[indexPath.section]
            let status = indexPath.section == mkmessages.count - 1 ? message.status + " " + message.readDate.time() : ""

            return NSAttributedString(string: status, attributes: [.font: UIFont.boldSystemFont(ofSize: 10), .foregroundColor: UIColor.darkGray])
        }
        return nil
    }

    
    //MARK: - Message Bottom Label
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        if indexPath.section != mkmessages.count - 1 {
            let font = UIFont.boldSystemFont(ofSize: 10)
            let color = UIColor.darkGray
            return NSAttributedString(string: message.sentDate.time(), attributes: [.font: font, .foregroundColor: color])
        } else {
            return nil
        }
    }
}




//MARK: - CHANNEL
extension ChannelChatViewController: MessagesDataSource {

    func currentSender() -> SenderType {

        return currentUser
    }

    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {

        return mkmessages.count
    }


    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {

        return mkmessages[indexPath.section]
    }

    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        if (indexPath.section % 3 == 0) {

            let showLoadMore = (indexPath.section == 0) && (allLocalMessages.count > displayingMessagesCount)
            let text = showLoadMore ? "Pull to load more" : MessageKitDateFormatter.shared.string(from: message.sentDate)
            let font = showLoadMore ? UIFont.systemFont(ofSize: 13) : UIFont.boldSystemFont(ofSize: 10)
            let color = showLoadMore ? UIColor.systemBlue : UIColor.darkGray
            return NSAttributedString(string: text, attributes: [.font: font, .foregroundColor: color])
        }
        return nil
    }


    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {

        return NSAttributedString(string: message.sentDate.time(), attributes: [.font : UIFont.boldSystemFont(ofSize: 10), .foregroundColor: UIColor.darkGray])
    }
}


