//
//  GlobalFunctions.swift
//  Chat
//
//  Created by David Kababyan on 13/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation

func removerCurrentUserFrom(userIds: [String]) -> [String] {
    
    var allIds = userIds
    
    allIds.remove(at: allIds.firstIndex(of: User.currentId())!)

    return allIds
}

