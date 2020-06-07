//
//  FCollectionReference.swift
//  Chat
//
//  Created by David Kababyan on 04/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import FirebaseFirestore


enum FCollectionReference: String {
    case User
    case Recent
    case Messages
    case Typing
}


func FirebaseReference(_ collectionReference: FCollectionReference) -> CollectionReference{
    return Firestore.firestore().collection(collectionReference.rawValue)
}
