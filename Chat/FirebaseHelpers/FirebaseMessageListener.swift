//
//  FirebaseMessageListener.swift
//  Chat
//
//  Created by David Kababyan on 14/08/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import FirebaseFirestoreSwift

class FirebaseMessageListener {
    
    static let shared = FirebaseMessageListener()
    
    private init() {}
    
    
    //MARK: - Add Update Delete
    /// Saves Specific Recent Object to firebase
    ///
    /// - Parameters:
    ///   - recent: The `Recent` Recent Object.
    func addMessage(_ message: LocalMessage, memberId: String) {
      do {
        let _ = try             FirebaseReference(.Messages).document(memberId).collection(message.chatRoomId).document(message.id).setData(from: message)
      }
      catch {
        print(error.localizedDescription, "adding message....")
      }
    }

    func addChannelMessage(_ message: LocalMessage, channel: Channel) {
      do {
        let _ = try FirebaseReference(.Messages).document(channel.id ?? "unknownChannel").collection(channel.id ?? "unknownChannel").document(message.id).setData(from: message)
      }
      catch {
        print(error.localizedDescription, "adding message....")
      }
    }


}
