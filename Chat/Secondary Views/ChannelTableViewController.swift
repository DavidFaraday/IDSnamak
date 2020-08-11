//
//  ChannelTableViewController.swift
//  Chat
//
//  Created by David Kababyan on 02/08/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

protocol ChannelTableViewControllerDelegate {
    func didClickFollow()
}

class ChannelTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var membersLabel: UILabel!
    @IBOutlet weak var aboutTextView: UITextView!
    
    
    //MARK: - Vars
    var channel: Channel!
    var delegate: ChannelTableViewControllerDelegate?

    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        showChannelData()
        configureRightBarButton()
    }
    
    //MARK: - Configure
    private func configureRightBarButton() {
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Follow", style: .done, target: self, action: #selector(followChannel))
    }
    
    private func showChannelData() {
        nameLabel.text = channel.name
        navigationItem.title = channel.name
        membersLabel.text = "\(channel.memberIds.count) Members"
        aboutTextView.text = channel.aboutChannel
        
        setAvatar(avatarLink: channel.avatarLink)
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

    //MARK: - Actions
    @objc func followChannel() {
        channel.memberIds.append(User.currentId)
        FirebaseChannelListener.shared.updateChannel(channel)
        delegate?.didClickFollow()
        self.navigationController?.popViewController(animated: true)
    }
}
