//
//  ChannelChatViewController.swift
//  Chat
//
//  Created by David Kababyan on 03/08/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase
import Gallery
import RealmSwift

class ChannelChatViewController: MessagesViewController {
    
    //MARK: - Vars
    private var chatId = ""
    private var recipientId = ""
    private var recipientName = ""

    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)

    var channel: Channel!
    
    let currentUser = MKSender(senderId: User.currentId(), displayName: User.currentUser()!.username)
    let refreshControl = UIRefreshControl()
    var gallery: GalleryController!

    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0

    var mkmessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!

    let realm = try! Realm()
    
    let micButton = InputBarButtonItem()

    //listeners
    var newChatListener: ListenerRegistration?
    var notificationToken: NotificationToken?

    var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName:String = ""
    var audioDuration:Date!

    //MARK: - Initialization
    init(channel: Channel) {

        super.init(nibName: nil, bundle: nil)

        self.chatId = channel.id
        self.recipientId = channel.id
        self.recipientName = channel.name
        self.channel = channel
    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never

        setChatTitle()
        
        configureLeftBarButton()
        
        configureMessageCollectionView()
        configureGestureRecognizer()
        configureMessageInputBar()
        loadChats()
        listenForNewChats()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
    }

    
    override func viewWillDisappear(_ animated: Bool) {
        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        audioController.stopAnyOngoingPlaying()
    }

    //MARK: - Configurations
    private func configureMessageCollectionView() {

        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self

        scrollsToBottomOnKeyboardBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.refreshControl = refreshControl
    }
    
    private func configureGestureRecognizer() {
        longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordAudio))
        longPressGesture.minimumPressDuration = 0.5
        longPressGesture.delaysTouchesBegan = true

    }

    private func configureMessageInputBar() {
        
        messageInputBar.isHidden = channel.adminId != User.currentId()
        
        messageInputBar.delegate = self

        let attachButton = InputBarButtonItem()
        attachButton.image = UIImage(systemName: "plus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 25))

        attachButton.setSize(CGSize(width: 30, height: 30), animated: false)
        
        attachButton.onKeyboardSwipeGesture { item, gesture in
            if (gesture.direction == .left)     { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 0, animated: true)        }
            if (gesture.direction == .right) { item.inputBarAccessoryView?.setLeftStackViewWidthConstant(to: 36, animated: true)    }
        }

        attachButton.onTouchUpInside { item in
            self.actionAttachMessage()
        }

        micButton.image = UIImage(named: "mic")
        micButton.setSize(CGSize(width: 30, height: 30), animated: false)
        micButton.addGestureRecognizer(longPressGesture)
        
        
        messageInputBar.setStackViewItems([attachButton], forStack: .left, animated: false)

        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)

        updateMicButtonStatus(show: true)
        
        messageInputBar.inputTextView.isImagePasteEnabled = false
        messageInputBar.backgroundView.backgroundColor = .systemBackground
        messageInputBar.inputTextView.backgroundColor = .systemBackground
    }
    
    func updateMicButtonStatus(show: Bool) {
        if show {
            messageInputBar.setStackViewItems([micButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 30, animated: false)
        } else {
            messageInputBar.setStackViewItems([messageInputBar.sendButton], forStack: .right, animated: false)
            messageInputBar.setRightStackViewWidthConstant(to: 55, animated: false)
        }
    }
    
    private func configureLeftBarButton() {
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(named: "back"), style: .plain, target: self, action: #selector(self.backButtonPressed))]

    }
    
    //MARK: - Load chats
    
    private func loadChats() {
                
        let predicate = NSPredicate(format: "chatRoomId = %@", chatId)
        
        allLocalMessages = realm.objects(LocalMessage.self).filter(predicate).sorted(byKeyPath: kDATE, ascending: true)

        if allLocalMessages.isEmpty {
            checkForOldChats()
        }
        
        notificationToken = allLocalMessages.observe({ (changes: RealmCollectionChange) in

            //updated message
            switch changes {
            case .initial:
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)

            case .update(_, _ , let insertions, _):

                for index in insertions {

                    self.insertMessage(self.allLocalMessages[index])
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: false)
                }
                
            case .error(let error):
                print("Error on new insertion", error.localizedDescription)
            }
        })
    }

    private func listenForNewChats() {
        
        newChatListener = FirebaseReference(.Messages).document(channel.id).collection(channel.id).whereField(kDATE, isGreaterThan: lastMessageDate()).addSnapshotListener({ (snapshot, error) in
            
            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                for change in snapshot.documentChanges {
                    
                    if change.type == .added {
                        createLocalMessage(messageDictionary: change.document.data())
                    }
                }
            }
        })
    }

    
    private func checkForOldChats() {
        
        FirebaseReference(.Messages).document(channel.id).collection(channel.id).getDocuments { (snapshot, error) in

            guard let snapshot = snapshot else { return }
            
            if !snapshot.isEmpty {
                
                let sortedMessageDictionary = ((self.dictionaryArrayFromSnapshots(snapshot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [Dictionary<String, Any>]
                
                for dictionary in sortedMessageDictionary {
                    createLocalMessage(messageDictionary: dictionary)
                }
            }
        }
    }


    private func insertMessages() {

        maxMessageNumber = allLocalMessages.count - displayingMessagesCount
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES

        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        
        for i in minMessageNumber ..< maxMessageNumber {
            insertMessage(allLocalMessages[i])
        }
    }

    private func insertMessage(_ localMessage: LocalMessage) {
        
        let incoming = IncomingMessage(collectionView_: self)
        self.mkmessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1

    }

    func insertOlderMessage(_ localMessage: LocalMessage) {
        
        let incoming = IncomingMessage(collectionView_: self)
        self.mkmessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
    }

    private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
        maxMessageNumber = minNumber - 1
        minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES
        
        if minMessageNumber < 0 {
            minMessageNumber = 0
        }
        

        for i in (minMessageNumber ... maxMessageNumber).reversed() {
            insertOlderMessage(allLocalMessages[i])
            displayingMessagesCount += 1
        }
    }

    
    //MARK: - SetupUI
    private func setChatTitle() {
        self.title = recipientName
    }


    //MARK: - Actions
    
    @objc func backButtonPressed() {
        
        removeListeners()
        self.navigationController?.popViewController(animated: true)
    }

    
    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {

        OutgoingMessage.sendChannel(channel: channel, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration,  location: location)
    }

    private func actionAttachMessage() {

        messageInputBar.inputTextView.resignFirstResponder()

        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let takePhotoOrVideo = UIAlertAction(title: NSLocalizedString("Camera", comment: ""), style: .default) { (alert: UIAlertAction!) in
            
            self.showImageGalleryFor(camera: true)
        }
        
        let shareMedia = UIAlertAction(title: NSLocalizedString("Library", comment: ""), style: .default) { (alert: UIAlertAction!) in
            
            self.showImageGalleryFor(camera: false)
        }
        
        let shareLocation = UIAlertAction(title: NSLocalizedString("Share Location", comment: ""), style: .default) { (alert: UIAlertAction!) in

            if let _ = LocationManager.shared.currentLocation {
                self.messageSend(text: nil, photo: nil, video: nil, audio: nil, location: kLOCATION)
            }
        }

        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        takePhotoOrVideo.setValue(UIImage(named: "cameraIcon"), forKey: "image")
        shareMedia.setValue(UIImage(named: "pictureLibrary"), forKey: "image")
        shareLocation.setValue(UIImage(named: "locationIcon"), forKey: "image")
        
        optionMenu.addAction(takePhotoOrVideo)
        optionMenu.addAction(shareMedia)
        optionMenu.addAction(shareLocation)
        optionMenu.addAction(cancelAction)
        
        self.present(optionMenu, animated: true, completion: nil)

    }

    // MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {

        if (refreshControl.isRefreshing) {
            
            if displayingMessagesCount < allLocalMessages.count {
                
                self.loadMoreMessages(maxNumber: maxMessageNumber, minNumber: minMessageNumber)
                messagesCollectionView.reloadDataAndKeepOffset()
            }
            refreshControl.endRefreshing()
        }
    }

    //MARK: - Helpers
    private func removeListeners() {
        
        if newChatListener != nil {
            newChatListener!.remove()
        }
    }

    private func lastMessageDate() -> Date {

        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        //add 1 sec from date because firebase will return same object in date less than date
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    

    private func dictionaryArrayFromSnapshots(_ snapshots: [DocumentSnapshot]) -> [Dictionary<String, Any>] {
        
        var allMessages: [Dictionary<String, Any>] = []
        
        for snapshot in snapshots {
            allMessages.append(snapshot.data()!)
        }
        
        return allMessages
    }

    
    

    //MARK: - Gallery
    private func showImageGalleryFor(camera: Bool) {
        self.gallery = GalleryController()
        self.gallery.delegate = self
        Config.tabsToShow = camera ? [.cameraTab] : [.imageTab, .videoTab]
        Config.Camera.imageLimit = 1
        Config.initialTab = .imageTab
        Config.VideoEditor.maximumDuration = 30

        self.present(self.gallery, animated: true, completion: nil)
    }
    
    //MARK: - AudioMessage
    @objc func recordAudio() {

        switch longPressGesture.state {
        case .began:
            
            AudioPlayer.shared.playSound(soundName: "ding", format: "mp3")
            
            audioDuration = Date()
            audioFileName = Date().stringDate()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
        case .ended:
            
            AudioRecorder.shared.finishRecording()

            if fileExistsAtPath(path: audioFileName + ".m4a") {
                let audioD = audioDuration.interval(ofComponent: .second, fromDate: Date())
                print("have file, duration ", audioDuration.interval(ofComponent: .second, fromDate: Date()))
                    
                messageSend(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioD)
            } else {
                print("no file")
            }
            
            audioFileName = ""
        @unknown default:
            print("unknown")
        }
    }

}



//MARK: - Gallery Delegate
extension ChannelChatViewController: GalleryControllerDelegate {
    
    func galleryController(_ controller: GalleryController, didSelectImages images: [Image]) {
        if images.count > 0 {
            images.first!.resolve(completion: { (image) in
                print("image")
                self.messageSend(text: nil, photo: image, video: nil, audio: nil, location: nil)
            })
        }
        
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryController(_ controller: GalleryController, didSelectVideo video: Video) {
        
        self.messageSend(text: nil, photo: nil, video: video, audio: nil, location: nil)
        
        controller.dismiss(animated: true, completion: nil)
    }

    func galleryController(_ controller: GalleryController, requestLightbox images: [Image]) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func galleryControllerDidCancel(_ controller: GalleryController) {
        controller.dismiss(animated: true, completion: nil)
    }

}
