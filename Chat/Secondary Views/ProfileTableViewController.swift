//
//  ProfileTableViewController.swift
//  Chat
//
//  Created by David Kababyan on 08/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class ProfileTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    
    //MARK: - Vars
    var user: User?

    //MARK: - View lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        setupUI()
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    //MARK: - Tableview Delegates
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.section == 1 {
            let chatId = startChat(user1: User.currentUser()!, user2: user!)
            
            let privateChatView = ChatViewController(chatId: chatId, recipientId: user!.id, recipientName: user!.username)

            privateChatView.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(privateChatView, animated: true)
        }
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableBackgroundColor")
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return ""
    }
    
    //MARK: - SetupUI
    private func setupUI() {
        if user != nil {
            userNameLabel.text = user!.username
            statusLabel.text = user!.status
            
            if user!.avatarLink != "" {
                FileStorage.downloadImage(imageUrl: user!.avatarLink) { (avatarImage) in
                    self.avatarImageView.image = avatarImage?.circleMasked
                }
            }
        }
    }

}
