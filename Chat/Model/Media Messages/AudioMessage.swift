//
//  AudioMessage.swift
//  Chat
//
//  Created by David Kababyan on 22/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import MessageKit

class AudioMessage: NSObject, AudioItem {

    var url: URL
    var size: CGSize
    var duration: Float

    init(duration: Float) {

        self.url = URL(fileURLWithPath: "")
        self.size = CGSize(width: 160, height: 35)
        self.duration = duration
    }
}
