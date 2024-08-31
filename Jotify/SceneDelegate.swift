//
//  SceneDelegate.swift
//  Jotify
//
//  Created by Harrison Leath on 1/16/21.
//

import UIKit
import SwiftUI
import Airbridge

class SceneDelegate: UIResponder, UIWindowSceneDelegate, UNUserNotificationCenterDelegate {
    
    var window: UIWindow?
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        
        UNUserNotificationCenter.current().delegate = self
                
        //handle initial setup from dedicated controller
        SetupController().handleApplicationSetup()
                
        //check if user is logged in
        if !AuthManager().uid.isEmpty {
            print("logged in")
            setupWindows(scene: scene, vc: PageBoyController())
        } else {
            print("not logged in")
            if SetupController.firstLauch ?? false {
                setupWindows(scene: scene, vc: OnboardingController())
            } else {
                setupWindows(scene: scene, vc: UIHostingController(rootView: SignUpView()))
            }
        }
        
        //pull up recent note widget launched app
        maybePressedRecentNoteWidget(urlContexts: connectionOptions.urlContexts)
        
        guard let _ = (scene as? UIWindowScene) else { return }
    }
    
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }
    
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }
    
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }
    
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
        //check if user is logged in
        if !AuthManager().uid.isEmpty {
            print("logged in")
            if UserDefaults.standard.bool(forKey: "useBiometrics") {
                let poc = PrivacyOverlayController()
                poc.modalPresentationStyle = .fullScreen
                window?.rootViewController?.present(poc, animated: false, completion: nil)
            }
        }
    }
    
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        ReminderController().renumberBadgesOfPendingNotifications()
        
        //Stop observing payment transaction updates
        IAPManager.shared.stopObserving()
    }
    
    func scene(_ scene: UIScene, continue userActivity: NSUserActivity) {
        if let userActivity = userActivity as? NSUserActivity {
            let isHandled = Airbridge.handleDeeplink(userActivity: userActivity) { url in
                // When the app is opened with an Airbridge deeplink
                // Show proper content using url (YOUR_SCHEME://...)
                self.handleDeeplink(url: url)
            }
            if isHandled {
                return
            }
        }
        // When the app is opened with other deeplink
        // Use existing logic as it is
    }
    
    //App opened from background - used partially for widgets
    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        print("Received a URL through a custom scheme...")
        guard let url = URLContexts.first?.url else { return }
        let isHandled = Airbridge.handleDeeplink(url: url) { url in
            // When the app is opened with an Airbridge deeplink
            // Show proper content using url (YOUR_SCHEME://...)
            self.handleDeeplink(url: url)
        }
        if isHandled {
            return
        }
        // When the app is opened with other deeplink
        // Use existing logic as it is
        maybePressedRecentNoteWidget(urlContexts: URLContexts)
    }
    
    func handleDeeplink(url: URL) {
        // Handle the deeplink URL
        // You can parse the URL and navigate to the appropriate screen or perform any other action
        print("Handling deeplink: \(url)")
        
        // Example: Extract referral ID from the URL
        if let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
           let queryItems = components.queryItems {
            for queryItem in queryItems {
                if queryItem.name == "referralId" {
                    UserDefaults.standard.set(queryItem.value, forKey: "referralId")
                    print("Referral ID: \(queryItem.value ?? "")")
                    break
                }
            }
        }
    }
    
    //collect data and present EditingController if widget pressed
    private func maybePressedRecentNoteWidget(urlContexts: Set<UIOpenURLContext>) {
        guard let _: UIOpenURLContext = urlContexts.first(where: { $0.url.scheme == "recentnotewidget-link" }) else { return }
        print("🚀 Launched from widget")
        
        //read data from GroupDataManager then create FBNote object
        let content = GroupDataManager.readData(path: "recentNoteContent")
        let color = GroupDataManager.readData(path: "recentNoteColor")
        let date = GroupDataManager.readData(path: "recentNoteDate")
        let id = GroupDataManager.readData(path: "recentNoteID")
        
        EditingData.currentNote = FBNote(content: content, timestamp: date.getTimestamp(), id: id, color: color)
        
        let presentable = StatusBarResponsiveNavigationController(rootViewController: EditingController())
        presentable.modalPresentationStyle = .fullScreen
        
        if !AuthManager().uid.isEmpty {
            print("logged in")
            if !UserDefaults.standard.bool(forKey: "useBiometrics") {
                window?.rootViewController?.present(presentable, animated: true, completion: nil)
            }
        }
    }
    
    func setupWindows(scene: UIScene, vc: UIViewController) {
        if let windowScene = scene as? UIWindowScene {
            let window = UIWindow(windowScene: windowScene)
            window.rootViewController = vc
            self.window = window
            window.makeKeyAndVisible()
        }
    }
    
    //app terminated when user interacts with notification
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        openNoteFromNotification(userInfo: userInfo)
        completionHandler(UIBackgroundFetchResult.noData)
    }
    
    //app in background when user interacts with notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        let userInfo = response.notification.request.content.userInfo
        
        if response.notification.request.content.categoryIdentifier ==
            "NOTE_REMINDER" {
            openNoteFromNotification(userInfo: userInfo)
        }
        else {
            // Handle other notification types...
        }
        completionHandler()
    }
    
    //app in foreground when user interacts with notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        //show an alert at top of screen while application is open
        completionHandler(UNNotificationPresentationOptions.alert)
    }
    
    func openNoteFromNotification(userInfo: [AnyHashable : Any]) {
        let noteID = userInfo["noteID"] as! String
        let color = userInfo["color"] as! String
        let timestamp = userInfo["timestamp"] as! Double
        let content = userInfo["content"] as! String
        
        print("NoteID from reminder: \(noteID)")
        
        EditingData.currentNote = FBNote(content: content, timestamp: timestamp, id: noteID, color: color)
        
        DataManager.removeReminder(uid: noteID) { success in
            if !success! {
                print("There was an error deleting the reminder")
            } else {
                print("Reminder was succesfully deleted and removed from backend")
                UIApplication.shared.applicationIconBadgeNumber -= 1
            }
        }
        
        let presentable = StatusBarResponsiveNavigationController(rootViewController: EditingController())
        presentable.modalPresentationStyle = .fullScreen
        window?.rootViewController?.present(presentable, animated: true)
    }
}

