//
//  AddChannelTableViewController.swift
//  Chat
//
//  Created by David Kababyan on 02/08/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import Gallery
import ProgressHUD

class AddChannelTableViewController: UITableViewController {

    //MARK: - IBOutlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var aboutTextView: UITextView!

    
    //MARK: - Vars
    var gallery: GalleryController!
    var tapGesture = UITapGestureRecognizer()
    var avatarLink = ""
    var channelId = UUID().uuidString
    
    var channelToEdit: Channel?
    
    //MARK: - View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never

        tableView.tableFooterView = UIView()
        configureGestures()
        configureLeftBarButton()
        
        if channelToEdit != nil {
            configureEditingView()
        }
    }

    
    //MARK: - IBActions
    @IBAction func saveBarButtonPressed(_ sender: Any) {
        if nameTextField.text != "" {
            channelToEdit != nil ? editChannel() : saveChannel()
        }else {
            ProgressHUD.showError("Channel Name is Empty!")
        }
    }
    
    @objc func avatarImageTap() {
        showImageGallery()
    }

    @objc func backButtonPressed() {
        self.navigationController?.popViewController(animated: true)
    }

    
    //MARK: - Save funcs
    private func saveChannel() {

        let channel = Channel(id: channelId, name: nameTextField.text!, adminId: User.currentId, memberIds: [User.currentId], avatarLink: avatarLink, aboutChannel: aboutTextView.text)

        FirebaseChannelListener.shared.saveChannel(channel)

        self.navigationController?.popViewController(animated: true)
    }
    
    private func editChannel() {

        channelToEdit!.name = nameTextField.text!
        channelToEdit!.avatarLink = avatarLink
        channelToEdit!.aboutChannel = aboutTextView.text

        FirebaseChannelListener.shared.saveChannel(channelToEdit!)

        self.navigationController?.popViewController(animated: true)
    }
    

    
    //MARK: - Configuration
    private func configureGestures() {
        tapGesture.addTarget(self, action: #selector(avatarImageTap))
        avatarImageView.isUserInteractionEnabled = true
        avatarImageView.addGestureRecognizer(tapGesture)
    }

    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]

    }
    
    private func configureEditingView() {
        self.nameTextField.text = channelToEdit!.name
        self.channelId = channelToEdit!.id
        self.aboutTextView.text = channelToEdit!.aboutChannel
        self.avatarLink = channelToEdit!.avatarLink
        self.title = "Editing Channel"

        setAvatar(avatarLink: channelToEdit!.avatarLink)
    }

    
    
    //MARK: - Gallery
    private func showImageGallery() {

        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = [.imageTab, .cameraTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab

        self.present(self.gallery, animated: true, completion: nil)
    }
    
    //MARK: - Avatars
    private func uploadAvatarImage(_ image: UIImage) {

        let fileDirectory = "Avatars/" + "_" + "\(channelId)" + ".jpg"

        FileStorage.uploadImage(image, directory: fileDirectory) { (avatarLink) in

            self.avatarLink = avatarLink ?? ""

            FileStorage.saveFileLocally(fileData: image.jpegData(compressionQuality: 1.0)! as NSData, fileName:  self.channelId)
        }
    }
    
    private func setAvatar(avatarLink: String) {

        if avatarLink != "" {
            FileStorage.downloadImage(imageUrl: avatarLink) { (avatarImage) in
                self.avatarImageView.image = avatarImage?.circleMasked
            }
        } else {
            self.avatarImageView.image = UIImage(named: "avatar")
        }
    }

}


extension AddChannelTableViewController: GalleryControllerDelegate {

    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {

        if images.count > 0 {

            images.first!.resolve(completion: { (icon) in

                if icon != nil {

                    self.uploadAvatarImage(icon!)
                    self.avatarImageView.image = icon?.circleMasked
                } else {
                    ProgressHUD.showFailed("Couldn't select Image!")
                }
            })
        }

        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
