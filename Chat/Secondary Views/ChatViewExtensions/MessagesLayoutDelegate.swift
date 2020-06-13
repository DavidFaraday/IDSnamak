//
//  MessagesLayoutDelegate.swift
//  Chat
//
//  Created by David Kababyan on 09/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import MessageKit

extension ChatViewController: MessagesLayoutDelegate {

    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

        if (indexPath.section % 3 == 0) {
            if ((indexPath.section == 0) && (allLocalMessages.count > displayingMessagesCount)) {

                return 40
            }
            return 18
        }
        return 0
    }


    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {

        return isFromCurrentSender(message: message) ? 17 : 0
    }

    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {

        avatarView.set(avatar: Avatar(initials: mkmessages[indexPath.section].senderInitials))

    }

}
