//
//  StatusTableViewController.swift
//  Chat
//
//  Created by David Kababyan on 06/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class StatusTableViewController: UITableViewController {

    //MARK: - Vars
    var allStatuses:[String] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        loadUserStatus()
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return allStatuses.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        
        let status = allStatuses[indexPath.row]
        cell.textLabel?.text = status
        
        cell.accessoryType = User.currentUser()?.status == status ? .checkmark : .none

        return cell
    }



    //MARK: - TableView Delegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        updateCellCheck(indexPath)
        tableView.reloadData()
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
       let headerView = UIView()
        headerView.backgroundColor = UIColor(named: "tableBackgroundColor")
        return headerView
    }

    
    //MARK: LoadUserDefaults
    private func loadUserStatus() {
        allStatuses = userDefaults.object(forKey: kSTATUS) as! [String]
        tableView.reloadData()
    }

    //MARK: - Helpers
    private func updateCellCheck(_ indexPath: IndexPath) {
        
        if let user = User.currentUser() {
            user.status = allStatuses[indexPath.row]
            user.saveUserLocally()
            user.saveUserToFireStore()
        }
    }


}
