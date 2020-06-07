//
//  ChatsTableViewController.swift
//  Chat
//
//  Created by David Kababyan on 06/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class ChatsTableViewController: UITableViewController {

    //MARK: - IBOutlets

    
    //MARK: - Vars
    var allRecents:[RecentChat] = []

    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.tableFooterView = UIView()

        navigationController?.navigationBar.prefersLargeTitles = true
        downloadRecentChats()
    }

    //MARK: - DownloadRecents
    private func downloadRecentChats() {
        FirebaseRecentListener.shared.downloadRecentChatsFromFireStore { (allChats) in

            self.allRecents = allChats
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }

    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {

        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return allRecents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentTableViewCell

        let recentChat = allRecents[indexPath.row]
        
        cell.configureCell(recent: recentChat)
        
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        FirebaseRecentListener.shared.clearUnreadCounter(recent: allRecents[indexPath.row])
        goToChat(recent: allRecents[indexPath.row])
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let recent = self.allRecents[indexPath.row]
            recent.deleteRecent()
            
            self.allRecents.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }

    
    //MARK: - Navigation
    private func goToChat(recent: RecentChat) {
        print(":Go to chat")
//        let privateChatView = ChatViewController(chatId: recent.chatRoomId, recipientId: recent.receiverId, recipientName: recent.receiverName)
//
//        privateChatView.hidesBottomBarWhenPushed = true
//        navigationController?.pushViewController(privateChatView, animated: true)
    }


}
