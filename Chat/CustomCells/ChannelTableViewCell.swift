//
//  ChannelTableViewCell.swift
//  Chat
//
//  Created by David Kababyan on 02/08/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {

    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var aboutLabel: UILabel!
    @IBOutlet weak var memberCountLabel: UILabel!
    @IBOutlet weak var lasstMessageDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(channel: Channel) {
        nameLabel.text = channel.name
        aboutLabel.text = channel.aboutChannel
        setAvatar(avatarLink: channel.avatarLink)
        memberCountLabel.text = "\(channel.memberIds.count) members"
        lasstMessageDateLabel.text = timeElapsed(channel.lastMessageDate)
        lasstMessageDateLabel.adjustsFontSizeToFitWidth = true
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
