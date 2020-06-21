//
//  ChatsTableViewController.swift
//  Chat
//
//  Created by David Kababyan on 06/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class ChatsTableViewController: UITableViewController {

    //MARK: - Vars
    var allRecents:[RecentChat] = []
    var filteredRecents:[RecentChat] = []

    let searchController = UISearchController(searchResultsController: nil)

    //MARK: - ViewLifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        createUsers()
        
        tableView.tableFooterView = UIView()

        downloadRecentChats()
        setupSearchController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationItem.largeTitleDisplayMode = .always
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    //MARK: - IBAction
    @IBAction func composeButtonPressed(_ sender: Any) {

        let userView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: "usersView") as! UsersTableViewController
        
        navigationController?.pushViewController(userView, animated: true)
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
     override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return searchController.isActive ? filteredRecents.count : allRecents.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! RecentTableViewCell

        let recentChat = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]

        cell.configureCell(recent: recentChat)
        
        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]

        FirebaseRecentListener.shared.clearUnreadCounter(recent: recent)
        goToChat(recent: recent)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let recent = searchController.isActive ? filteredRecents[indexPath.row] : allRecents[indexPath.row]
            recent.deleteRecent()
            
            searchController.isActive ? self.filteredRecents.remove(at: indexPath.row) : self.allRecents.remove(at: indexPath.row)
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return true
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableBackgroundColor")
        return headerView
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }

    
    //MARK: - Navigation
    private func goToChat(recent: RecentChat) {

        restartChat(chatRoomId: recent.chatRoomId, memberIds: recent.memberIds)

        let privateChatView = ChatViewController(chatId: recent.chatRoomId, recipientId: recent.receiverId, recipientName: recent.receiverName)

        privateChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(privateChatView, animated: true)
    }

    //MARK: - SearchController
    private func setupSearchController() {
        
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search User"
        searchController.searchResultsUpdater = self
        definesPresentationContext = true
    }

    private func filteredContentForSearchText(searchText: String) {
        
        filteredRecents = allRecents.filter({ (recent) -> Bool in
            
            return recent.receiverName.lowercased().contains(searchText.lowercased())
        })
        
        tableView.reloadData()
    }
}


extension ChatsTableViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filteredContentForSearchText(searchText: searchController.searchBar.text!)
    }
    
}
