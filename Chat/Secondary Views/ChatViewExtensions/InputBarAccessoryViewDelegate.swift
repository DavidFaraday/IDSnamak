//
//  InputBarAccessoryViewDelegate.swift
//  Chat
//
//  Created by David Kababyan on 09/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import InputBarAccessoryView

extension ChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
        //we don't want to show typing when we empty the text field, after we press send
        if text != "" {
            typingIndicatorUpdate()
        }
        
        updateMicButtonStatus(show: text == "")
    }


    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                messageSend(text: text, photo: nil, video: nil, audio: nil, location: nil)
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}



//MARK: - Channel

extension ChannelChatViewController: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, textViewTextDidChangeTo text: String) {
          
        updateMicButtonStatus(show: text == "")
    }


    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {

        for component in inputBar.inputTextView.components {
            if let text = component as? String {
                messageSend(text: text, photo: nil, video: nil, audio: nil, location: nil)
            }
        }
        messageInputBar.inputTextView.text = ""
        messageInputBar.invalidatePlugins()
    }
}


