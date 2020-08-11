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
        unreadCountBackgroundView.layer.cornerRadius = unreadCountBackgroundView.frame.width/2
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
            timeLabel.text = timeElapsed(recent.date ?? Date())
            timeLabel.adjustsFontSizeToFitWidth = true

    }

    private func setAvatar(avatarLink: String) {
        
        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")?.circleMasked
        }
    }
        

}
