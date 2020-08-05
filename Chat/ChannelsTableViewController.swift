//
//  ChannelsTableViewController.swift
//  Chat
//
//  Created by David Kababyan on 02/08/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit

class ChannelsTableViewController: UITableViewController {

    
    //MARK: - IBOutlets
    
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var channelSegmentOutlet: UISegmentedControl!
    
    //MARK: - Vars
    var allChannels:[Channel] = []
    var subscribedChannels:[Channel] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.refreshControl = UIRefreshControl()
        self.tableView.refreshControl = self.refreshControl
                
        tableView.tableHeaderView = headerView
        downloadChannels()
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return channelSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels.count : allChannels.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! ChannelTableViewCell

        let channel = channelSegmentOutlet.selectedSegmentIndex == 0 ? subscribedChannels[indexPath.row] : allChannels[indexPath.row]

        cell.configure(channel: channel)
        
        return cell
    }

    //MARK: - TableViewDelegate
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        if channelSegmentOutlet.selectedSegmentIndex == 1 {
            showChannelView(channel: allChannels[indexPath.row])
        } else {
            showChat(channel: subscribedChannels[indexPath.row])
        }
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        let tempChannel = channelSegmentOutlet.selectedSegmentIndex == 1 ? allChannels[indexPath.row] : subscribedChannels[indexPath.row]

        return tempChannel.adminId != User.currentId()
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            let channelToDelete: Channel!
            
            if channelSegmentOutlet.selectedSegmentIndex == 1 {
                channelToDelete = allChannels[indexPath.row]
                allChannels.remove(at: indexPath.row)
            } else {
                channelToDelete = subscribedChannels[indexPath.row]
                subscribedChannels.remove(at: indexPath.row)
            }

            if let index = channelToDelete.memberIds.firstIndex(of: User.currentId()) {
                channelToDelete.memberIds.remove(at: index)
            }
            
            channelToDelete.editChannel(withValues: [kMEMBERIDS : channelToDelete.memberIds])
            tableView.reloadData()
        }
    }
    
    
    //MARK: - Download Channels
    private func downloadChannels() {
        
        FirebaseChannelListener.shared.downloadAllChannels { (allChannels) in
            
            self.allChannels = allChannels
            
            if self.channelSegmentOutlet.selectedSegmentIndex == 1 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        
        FirebaseChannelListener.shared.downloadSubscribedChannels { (subscribedChannels) in
            
            self.subscribedChannels = subscribedChannels
            if self.channelSegmentOutlet.selectedSegmentIndex == 0 {
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
    }

    
    //MARK: - IBActions
    @IBAction func channelSegmentValueChanged(_ sender: UISegmentedControl) {
        tableView.reloadData()
    }
    
    
    //MARK: - Navigations
    private func showChannelView(channel: Channel) {
        let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(identifier: "channelView") as! ChannelTableViewController
        
        vc.channel = channel
        vc.delegate = self
        self.navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - UIScrollViewDelegate
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        if self.refreshControl!.isRefreshing {
            self.downloadChannels()
            self.refreshControl!.endRefreshing()
        }
    }
    
    //MARK: - Navigation
    private func showChat(channel: Channel) {

        let channelChatView = ChannelChatViewController(channel: channel)
        
        channelChatView.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(channelChatView, animated: true)
    }

}


extension ChannelsTableViewController: ChannelTableViewControllerDelegate {
    func didClickFollow() {
        downloadChannels()
    }
}
