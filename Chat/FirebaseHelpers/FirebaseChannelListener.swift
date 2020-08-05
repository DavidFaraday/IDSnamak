//
//  FirebaseChannelListener.swift
//  Chat
//
//  Created by David Kababyan on 02/08/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import Firebase

class FirebaseChannelListener {
    
    static let shared = FirebaseChannelListener()
    
    var channelListener: ListenerRegistration!

    private init() {}
 
    func downloadUserChannelsFromFireStore(completion: @escaping (_ allRecents: [Channel]) -> Void) {
        
        channelListener = FirebaseReference(.Channel).whereField(kADMINID, isEqualTo: User.currentId()).addSnapshotListener() { (snapshot, error) in
        
            var allChannels: [Channel] = []

            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {

                for channelDocument in snapshot.documents {

                    allChannels.append(Channel(channelDocument.data()))
                }

                allChannels.sort(by: { $0.createdDate > $1.createdDate })
                completion(allChannels)
                
            } else {
                completion(allChannels)
            }
        }
    }
    
    func downloadSubscribedChannels(completion: @escaping (_ allRecents: [Channel]) -> Void) {
        
        channelListener = FirebaseReference(.Channel).whereField(kMEMBERIDS, arrayContains: User.currentId()).addSnapshotListener() { (snapshot, error) in

            var allChannels: [Channel] = []

            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {

                for channelDocument in snapshot.documents {

                    allChannels.append(Channel(channelDocument.data()))
                }

                allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
                completion(allChannels)
                
            } else {
                completion(allChannels)
            }
        }
    }

    
    func downloadAllChannels(completion: @escaping (_ allRecents: [Channel]) -> Void) {
        
        FirebaseReference(.Channel).getDocuments { (snapshot, error) in
            
            var allChannels: [Channel] = []

            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {

                for channelDocument in snapshot.documents {
                    
                    let channel = Channel(channelDocument.data())
                    if !channel.memberIds.contains(User.currentId()) {
                        allChannels.append(channel)
                    }
                }

                allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
                completion(allChannels)
                
            } else {
                completion(allChannels)
            }
        }
    }

    
    func removeChannelListener() {
        self.channelListener.remove()
    }


}
