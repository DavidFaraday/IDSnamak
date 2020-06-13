//
//  MessageCellDelegate.swift
//  Chat
//
//  Created by David Kababyan on 09/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import MessageKit

extension ChatViewController: MessageCellDelegate {

    func didTapImage(in cell: MessageCollectionViewCell) {

        if let indexPath = messagesCollectionView.indexPath(for: cell) {
//            let mkmessage = mkmessageAt(indexPath)
//
//            if (mkmessage.type == MESSAGE_PHOTO) {
//            }
        }
    }
}
