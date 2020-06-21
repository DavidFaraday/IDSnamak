//
//  PhotoMessage.swift
//  Chat
//
//  Created by David Kababyan on 14/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import MessageKit

class PhotoMessage: NSObject, MediaItem {

    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize

    init(path: String) {
        self.url = URL(fileURLWithPath: path)
        self.placeholderImage = UIImage(named: "photoPlaceholder")!
        self.size = CGSize(width: 240, height: 240)
    }
}
