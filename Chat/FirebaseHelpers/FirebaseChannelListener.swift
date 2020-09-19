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

    private init() {}

    //MARK: - Fetching
    func downloadUserChannelsFromFireStore(completion: @escaping (_ allChannel: [Channel]) -> Void) {

        FirebaseReference(.Channel).whereField(kADMINID, isEqualTo: User.currentId).addSnapshotListener() { (querySnapshot, error) in

            guard let documents = querySnapshot?.documents else {
                print("no document for user channels")
                return
            }

            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                print(queryDocumentSnapshot)
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }

            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)

        }
    }
    
    func downloadSubscribedChannels(completion: @escaping (_ allChannel: [Channel]) -> Void) {
        
        FirebaseReference(.Channel).whereField(kMEMBERIDS, arrayContains: User.currentId).addSnapshotListener() { (querySnapshot, error) in

            guard let documents = querySnapshot?.documents else {
                print("no document for subscribed channels")
                return
            }
            
            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }
            
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
            
        }
    }

    
    func downloadAllChannels(completion: @escaping (_ allChannel: [Channel]) -> Void) {

        FirebaseReference(.Channel).getDocuments { (querySnapshot, error) in

            guard let documents = querySnapshot?.documents else {
                print("no document for all channels")
                return
            }

            var allChannels = documents.compactMap { (queryDocumentSnapshot) -> Channel? in
                return try? queryDocumentSnapshot.data(as: Channel.self)
            }

            allChannels = self.removeSubscribedChannels(allChannels)
            allChannels.sort(by: { $0.memberIds.count > $1.memberIds.count })
            completion(allChannels)
        }
    }

    
    //MARK: - Add Update Delete
    func saveChannel(_ channel: Channel) {
        do {
            let _ = try FirebaseReference(.Channel).document(channel.id).setData(from: channel)
        }
        catch {
            print(error.localizedDescription, "adding channel....")
        }
    }
    

    func deleteChannel(_ channel: Channel) {
        FirebaseReference(.Channel).document(channel.id).delete()
    }


    
    //MARK: - Helpers
    func removeSubscribedChannels(_ allChannels: [Channel]) -> [Channel] {
        
        var newChannels: [Channel] = []
        
        for channel in allChannels {
            if !channel.memberIds.contains(User.currentId) {
                newChannels.append(channel)
            }
        }
        
        return newChannels
    }
}
