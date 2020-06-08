//
//  RecentTableViewCell.swift
//  Chat
//
//  Created by David Kababyan on 06/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class RecentTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    
    //UIViews
    @IBOutlet weak var unreadCountBackgroundView: UIView!
    
    //ImageViews
    @IBOutlet weak var avatarImageView: UIImageView!
    
    //Labels
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var lastMessageLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var unreadCountLabel: UILabel!
    
    //MARK: - ViewLifeCycle
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureCell(recent: RecentChat) {
        
            userNameLabel.text = recent.receiverName
            lastMessageLabel.text = recent.lastMessage
            lastMessageLabel.adjustsFontSizeToFitWidth = true
            
            //set counter if available
            if recent.unreadCounter != 0 {
                self.unreadCountLabel.text = "\(recent.unreadCounter)"
                self.unreadCountBackgroundView.isHidden = false
                self.unreadCountBackgroundView.isHidden = false
            } else {
                self.unreadCountBackgroundView.isHidden = true
                self.unreadCountBackgroundView.isHidden = true
            }
        
            setAvatar(avatarLink: recent.avatarLink)
            timeLabel.text = timeElapsed(recent.date)
            timeLabel.adjustsFontSizeToFitWidth = true

    }

    private func setAvatar(avatarLink: String) {
        
        FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
            if avatarImage != nil {
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        }
    }
        
    func timeElapsed(_ date: Date) -> String {
        
        let seconds = Date().timeIntervalSince(date)

        var elapsed = ""
        
        if (seconds < 60) {
            elapsed = "Just now"
        } else if (seconds < 60 * 60) {
            let minutes = Int(seconds / 60)
            
            var minText = "min"
            if minutes > 1 {
                minText = "mins"
            }
            elapsed = "\(minutes) \(minText)"
            
        } else if (seconds < 24 * 60 * 60) {
            
            let hours = Int(seconds / (60 * 60))
            var hourText = "hour"
            if hours > 1 {
                hourText = "hours"
            }
            
            elapsed = "\(hours) \(hourText)"
            
        } else {
            
            elapsed = date.longDate()
        }
        
        return elapsed
    }

}
