//
//  Channel.swift
//  Chat
//
//  Created by David Kababyan on 02/08/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import Firebase

class Channel: Codable {
    
    var id = ""
    var name = ""
    var adminId = ""
    var memberIds = [""]
    var avatarLink = ""
    var aboutChannel = ""
    var createdDate = Date()
    var lastMessageDate = Date()
    
    
    var dictionary: NSDictionary {
        
        return NSDictionary(objects: [self.id,
                                      self.name,
                                      self.adminId,
                                      self.memberIds,
                                      self.avatarLink,
                                      self.aboutChannel,
                                      self.createdDate,
                                      self.lastMessageDate
                            ],
                            forKeys: [kID as NSCopying,
                                      kNAME as NSCopying,
                                      kADMINID as NSCopying,
                                      kMEMBERIDS as NSCopying,
                                      kAVATARLINK as NSCopying,
                                      kABOUTCHANNEL as NSCopying,
                                      kCREATEDDATE as NSCopying,
                                      kDATE as NSCopying
                            ]
        )
    }

    
    init() { }
    
    init(_ recentDocument: Dictionary<String, Any>) {
        
        id = recentDocument[kID] as? String ?? ""
        name = recentDocument[kNAME] as? String ?? ""
        adminId = recentDocument[kADMINID] as? String ?? ""
        memberIds = recentDocument[kMEMBERIDS] as? [String] ?? [""]
        avatarLink = recentDocument[kAVATARLINK] as? String ?? ""
        aboutChannel = recentDocument[kABOUTCHANNEL] as? String ?? ""
        createdDate = (recentDocument[kCREATEDDATE] as? Timestamp)?.dateValue() ?? Date()
        lastMessageDate = (recentDocument[kDATE] as? Timestamp)?.dateValue() ?? Date()
    }

    //MARK: - Saving
    func saveToFirestore() {
        FirebaseReference(.Channel).document(self.id).setData(self.dictionary as! [String : Any])
    }
    
    func deleteChannel() {
        FirebaseReference(.Channel).document(self.id).delete()
    }
    
    func editChannel(withValues: [String : Any]) {
        FirebaseReference(.Channel).document(self.id).updateData(withValues)
    }

}
