//
//  ChatViewController.swift
//  Chat
//
//  Created by David Kababyan on 08/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase
import Gallery
import RealmSwift

class ChatViewController: MessagesViewController {
    //MARK: - Views
    let leftBarButtonView: UIView = {

        let view = UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 50))
        return view
    }()

    let avatarButton: UIButton = {

        let myButton = UIButton(frame: CGRect(x: 0, y: 5, width: 25, height: 25))

        return myButton
    }()
    let titleLabel: UILabel = {

        let title = UILabel(frame: CGRect(x: 5, y: 0, width: 140, height: 25))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 16, weight: .medium)

        return title
    }()
    let subTitleLabel: UILabel = {

        let title = UILabel(frame: CGRect(x: 5, y: 22, width: 140, height: 20))
        title.textAlignment = .left
        title.font = UIFont.systemFont(ofSize: 13, weight: .medium)

        return title
    }()
    

    //MARK: - Vars
    var chatId = ""
    private var recipientId = ""
    private var recipientName = ""

    open lazy var audioController = BasicAudioController(messageCollectionView: messagesCollectionView)

    let currentUser = MKSender(senderId: User.currentId, displayName: User.currentUser!.username)
    let refreshControl = UIRefreshControl()

    var gallery: GalleryController!

    var displayingMessagesCount = 0
    var maxMessageNumber = 0
    var minMessageNumber = 0

    var typingCounter = 0
    var mkmessages: [MKMessage] = []
    var allLocalMessages: Results<LocalMessage>!

    let realm = try! Realm()

    let micButton = InputBarButtonItem()

    //listeners
    var notificationToken: NotificationToken?

    var longPressGesture: UILongPressGestureRecognizer!
    var audioFileName:String = ""
    var audioDuration:Date!

    //MARK: - Initialization
    init(chatId: String, recipientId: String, recipientName: String) {

        super.init(nibName: nil, bundle: nil)

        self.chatId = chatId
        self.recipientId = recipientId
        self.recipientName = recipientName

    }

    required init?(coder aDecoder: NSCoder) {

        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never

        createTypingObserver()

        configureLeftBarButton()
        configureCustomTitle()

        configureMessageCollectionView()

        configureGestureRecognizer()

        configureMessageInputBar()
        loadChats()
        listenForNewChats()
        listenForReadStatusChange()
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

        micButton.image = UIImage(systemName: "mic.fill", withConfiguration: UIImage.SymbolConfiguration(pointSize: 30))


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
        self.navigationItem.leftBarButtonItems = [UIBarButtonItem(image: UIImage(systemName: "chevron.left"), style: .plain, target: self, action: #selector(self.backButtonPressed))]
    }
    
    func configureCustomTitle() {
//        leftBarButtonView.addSubview(avatarButton)
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)

        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)

        self.navigationItem.leftBarButtonItems?.append(leftBarButtonItem)

        titleLabel.text = recipientName
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
                print("loadChats initial from realm db")
                self.insertMessages()
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: true)

            case .update(_, _ , let insertions, _):

                for index in insertions {
                    print("loadChats insertion to realm ", self.allLocalMessages[index].message, self.allLocalMessages[index].status)

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

        FirebaseMessageListener.shared.listenForNewChats(User.currentId, collectionId: chatId, lastMessageDate: lastMessageDate())
    }


    private func checkForOldChats() {

        FirebaseMessageListener.shared.checkForOldChats(User.currentId, collectionId: chatId)
    }

    
    private func listenForReadStatusChange() {

        FirebaseMessageListener.shared.listenForReadStatusChange(User.currentId, collectionId: chatId) { (updatedMessage) in

            if updatedMessage.status != kSENT {
                print("listenForReadStatusChange: updating message received from firebase",updatedMessage.message, updatedMessage.status)

                self.updateMessage(updatedMessage)
            } else {
                print("message update received from FB but we dont update locally",updatedMessage.message, updatedMessage.status)

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

        if localMessage.senderId != User.currentId {
            markMessageAsRead(localMessage)
        }

        let incoming = IncomingMessage(collectionView_: self)
        self.mkmessages.append(incoming.createMessage(localMessage: localMessage)!)
        displayingMessagesCount += 1
    }

        private func loadMoreMessages(maxNumber: Int, minNumber: Int) {
            maxMessageNumber = minNumber - 1
            minMessageNumber = maxMessageNumber - kNUMBEROFMESSAGES

            if minMessageNumber < 0 {
                minMessageNumber = 0
            }


            for i in (minMessageNumber ... maxMessageNumber).reversed() {
                insertOlderMessage(allLocalMessages[i])
            }
        }

    func insertOlderMessage(_ localMessage: LocalMessage) {

        let incoming = IncomingMessage(collectionView_: self)
        self.mkmessages.insert(incoming.createMessage(localMessage: localMessage)!, at: 0)
            displayingMessagesCount += 1
    }


    //MARK: - UpdateReadMessagesStatus
    func updateMessage(_ localMessage: LocalMessage) {

        for index in 0 ..< mkmessages.count {

            let tempMessage = mkmessages[index]

            if localMessage.id == tempMessage.messageId {
                print("DEBUG:...updating local message in realm", localMessage.message, localMessage.status)

                mkmessages[index].status = localMessage.status
                mkmessages[index].readDate = localMessage.readDate

                RealmManager.shared.saveToRealm(localMessage)

                if mkmessages[index].status == kREAD {
                    self.messagesCollectionView.reloadData()
                }
            }
        }
    }

    private func markMessageAsRead(_ localMessage: LocalMessage) {


        if localMessage.senderId != User.currentId && localMessage.status != kREAD  {
            print("markMessageAsRead:...marking message as read on fb", localMessage.message, localMessage.status)

            FirebaseMessageListener.shared.updateMessageInFireStore(localMessage, memberIds: [User.currentId, recipientId])
        }
    }

    
    //MARK: - Actions
    @objc func backButtonPressed() {

        FirebaseRecentListener.shared.resetRecentCounter(chatRoomId: chatId)
        removeListeners()
        self.navigationController?.popToRootViewController(animated: true)
    }

    
    func messageSend(text: String?, photo: UIImage?, video: Video?, audio: String?, location: String?, audioDuration: Float = 0.0) {

        OutgoingMessage.send(chatId: chatId, text: text, photo: photo, video: video, audio: audio, audioDuration: audioDuration, location: location, memberIds: [User.currentId, recipientId])
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

        takePhotoOrVideo.setValue(UIImage(systemName: "camera"), forKey: "image")
        shareMedia.setValue(UIImage(systemName: "photo.fill"), forKey: "image")
        shareLocation.setValue(UIImage(systemName: "mappin.and.ellipse"), forKey: "image")

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
        FirebaseTypingListener.shared.removeTypingListener()
        FirebaseMessageListener.shared.removeMessageListener()
    }

    private func lastMessageDate() -> Date {

        let lastMessageDate = allLocalMessages.last?.date ?? Date()
        //add 1 sec from date because firebase will return same object in date less than date
        return Calendar.current.date(byAdding: .second, value: 1, to: lastMessageDate) ?? lastMessageDate
    }
    

    //MARK: - TypingIndicator
    func createTypingObserver() {

        FirebaseTypingListener.shared.createTypingObserver(chatRoomId: chatId, completion: { (isTyping) in

            DispatchQueue.main.async {
                self.updateTypingIndicator(isTyping)
            }
        })
    }

    
    func typingIndicatorUpdate() {

        typingCounter += 1

        FirebaseTypingListener.saveTypingCounter(typing: true, chatRoomId: chatId)

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.typingCounterStop()
        }
    }
    
    func typingCounterStop() {
        typingCounter -= 1

        if typingCounter == 0 {
            FirebaseTypingListener.saveTypingCounter(typing: false, chatRoomId: chatId)
        }
    }

        func updateTypingIndicator(_ show: Bool) {

            subTitleLabel.text = show ? "Typing..." : ""
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

            audioDuration = Date()
            audioFileName = Date().stringDate()
            AudioRecorder.shared.startRecording(fileName: audioFileName)
        case .ended:

            AudioRecorder.shared.finishRecording()

            if fileExistsAtPath(path: audioFileName + ".m4a") {
                let audioD = audioDuration.interval(ofComponent: .second, fromDate: Date())

                messageSend(text: nil, photo: nil, video: nil, audio: audioFileName, location: nil, audioDuration: audioD)
            } else {
                print("no audio file")
            }

            audioFileName = ""
        case .possible:
            print("possible")
        case .changed:
            print("changed")
        case .cancelled:
            print("cancelled")
        case .failed:
            print("failed")
        @unknown default:
            print("unknown")
        }
    }

    }


//MARK: - Gallery Delegate
extension ChatViewController: GalleryControllerDelegate {
    
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
