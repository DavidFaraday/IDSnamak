//
//  AppDelegate.swift
//  Chat
//
//  Created by David Kababyan on 03/06/2020.
//  Copyright © 2020 David Kababyan. All rights reserved.
//

import UIKit
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var firstRun: Bool?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        FirebaseApp.configure()
        Messaging.messaging().delegate = self
        requestPushNotificationPermission()

        firstRunCheck()
        
        application.registerForRemoteNotifications()
        application.applicationIconBadgeNumber = 0

        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    //added for notifications
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any]) {
        
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any],
                     fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

      completionHandler(UIBackgroundFetchResult.newData)
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
      print("Unable to register for remote notifications: \(error.localizedDescription)")
    }

    
    //MARK: - FirstRunCheck
    private func firstRunCheck() {
        
        firstRun = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !firstRun! {
            let status = Status.array.map { $0.rawValue }
            
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(status, forKey: kSTATUS)
            
            userDefaults.synchronize()
        }
    }

    //MARK: - PushNotifications
    private func requestPushNotificationPermission() {
        UNUserNotificationCenter.current().delegate = self

        let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        UNUserNotificationCenter.current().requestAuthorization(
          options: authOptions,
          completionHandler: {_, _ in })

    }
    
    private func updateUserPushId(newPushId: String) {
        
        if let user = User.currentUser() {
            user.pushId = newPushId
            user.saveUserLocally()
            FirebaseUserListener.shared.updateUserInFireStore(withValues: [kPUSHID : newPushId]) { (error) in
                print("updated push id and error is ", error)
            }
        }
    }

}

extension AppDelegate : UNUserNotificationCenterDelegate {
    
    
}


extension AppDelegate : MessagingDelegate {
    
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String) {
        print("token is", fcmToken)
        updateUserPushId(newPushId: fcmToken)
    }
}
