//
//  GlobalFunctions.swift
//  Chat
//
//  Created by David Kababyan on 13/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

func removerCurrentUserFrom(userIds: [String]) -> [String] {
    
    var allIds = userIds
    for id in allIds {
     
        if id == User.currentId() {
            allIds.remove(at: allIds.firstIndex(of: id)!)
        }
    }
    return allIds
    
}

func fileNameFrom(fileUrl: String) -> String {
    
    return ((fileUrl.components(separatedBy: "_").last!).components(separatedBy: "?").first!).components(separatedBy: ".").first!
}


func videoThumbnail(video: URL) -> UIImage {
    
    let asset = AVURLAsset(url: video, options: nil)
    
    let imageGenerator = AVAssetImageGenerator(asset: asset)
    imageGenerator.appliesPreferredTrackTransform = true
    
    let time = CMTimeMakeWithSeconds(0.5, preferredTimescale: 1000)
    var actualTime = CMTime.zero
    
    var image: CGImage?
    
    do {
        image = try imageGenerator.copyCGImage(at: time, actualTime: &actualTime)
    }
    catch let error as NSError {
        print(error.localizedDescription)
    }
    
    let thumbnail = UIImage(cgImage: image!)
    
    return thumbnail
}
