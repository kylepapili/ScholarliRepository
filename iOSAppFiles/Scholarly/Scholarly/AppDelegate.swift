//
//  AppDelegate.swift
//  Scholarly
//
//  Created by Kyle Papili on 6/20/17.
//  Copyright © 2017 Scholarly. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import FirebaseMessaging
import UserNotifications
import BRYXBanner


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate , MessagingDelegate {
    
    var didLaunchFromBackground : Bool = false
    var backgroundLaunchClassID : String = ""
    var window: UIWindow?
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        //MARK: - Keyboard Manager
        IQKeyboardManager.sharedManager().enable = true
        IQKeyboardManager.sharedManager().enableAutoToolbar = true
        
        //Notifications Setup
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
            
            // For iOS 10 data message (sent via FCM)
            Messaging.messaging().remoteMessageDelegate = self
            
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        // Root View Controller
        FirebaseApp.configure()
        let storyboard =  UIStoryboard(name: "Main", bundle: Bundle.main)
        var currentUser = Auth.auth().currentUser
        
        //currentUser = nil
        
        if currentUser != nil {
            print("USER FOUND")
            //Need to check if: 1. User exists 2. User completed setup 3. App did or did not launch from background
            doesUserExist(userToTest: currentUser, completion: { (userExists, completedSetup) in
                print("User Exists: \(userExists)")
                print("Completed Setup: \(completedSetup)")
                
                if userExists {
                    if completedSetup {
                        //User is singed in and completed setup
                        prepareUserDefaults(completionHandler: {
                            prepareClassData(completionHandler: { (FinalClassData) in
                                if (FinalClassData != nil) {
                                    UniversalClassData = FinalClassData
                                    application.applicationIconBadgeNumber = 0
                                    if self.didLaunchFromBackground {
                                        //Application DID launch from background notification
                                        
                                        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                        guard let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "HomeScreenVC") as? TabController else {
                                            print("ERROR")
                                            return
                                        }
                                        self.window = UIWindow(frame: UIScreen.main.bounds)
                                        
                                        UIView.transition(with: self.window!, duration: 0.3, options: .transitionCurlUp, animations: {
                                            print("LAUNCHED FROM BACKGROUND NOTIFICATION!!!!!******!!!***!!!***!!!***")
                                            print(self.backgroundLaunchClassID)
                                            self.window?.rootViewController = initialViewControlleripad
                                            
                                            self.window?.makeKeyAndVisible()
                                        }, completion: { completed in
                                            // maybe do something here
                                        })
                                    } else {
                                        //Application DID NOT launch from background notification
                                        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
                                        guard let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "HomeScreenVC") as? TabController else {
                                            print("ERROR")
                                            return
                                        }
                                        self.window = UIWindow(frame: UIScreen.main.bounds)
                                        
                                        UIView.transition(with: self.window!, duration: 0.3, options: .transitionCurlUp, animations: {
                                            self.window?.rootViewController = initialViewControlleripad
                                            
                                            self.window?.makeKeyAndVisible()
                                        }, completion: { completed in
                                            // maybe do something here
                                        })
                                    }
                                }
                            })
                        })
                        
                    } else {
                        //User exists but needs to complete setup
                        self.userNeedsToCompleteSetup()
                    }
                } else {
                    self.redirectToLoginScreen()
                }
            })
        }
        else {
            redirectToLoginScreen()
        }
        
        return true
    }
    
    func redirectToLoginScreen() {
        print("NO USER FOUND")
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "LoginScreenVC") as! LoginScreenViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewControlleripad
        self.window?.makeKeyAndVisible()
    }
    
    func userNeedsToCompleteSetup() {
        print("User needs to complete setup")
        let mainStoryboardIpad : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        let initialViewControlleripad : UIViewController = mainStoryboardIpad.instantiateViewController(withIdentifier: "FirstPageVC") as! UIViewController
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.rootViewController = initialViewControlleripad
        self.window?.makeKeyAndVisible()
    }
    
    func GoToClassVC(fromVC : UIViewController, toClassID: String) {
        let storyboard : UIStoryboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let navVC = storyboard.instantiateViewController(withIdentifier: "initialNavVC") as? UINavigationController else {
            print("ERROR IN GoToClassVC 1")
            return
        }
        
        guard let FirstVC = storyboard.instantiateViewController(withIdentifier: "MessageScreenVC") as? FirstViewController else {
            print("Error in GoToClassVC 2")
            return
        }
        
        guard let TabBar = storyboard.instantiateViewController(withIdentifier: "HomeScreenVC") as? TabController else {
            print("Error in GoToClassVC 4")
            return
        }
        
        //Current issue is that the Nav View Controller is presented without the TabBarController. Need to switch TabBar to NavVC, Pop to FirstVC, and performSegue to ChatLogVC
        let allVC = navVC.viewControllers
        self.window?.rootViewController = navVC
        navVC.popToViewController(allVC[0], animated: true)
        self.window?.makeKeyAndVisible()
        
        
        (allVC[0] as! FirstViewController).loadChatVCFromNotification(withClassID: toClassID)
        
    }
    
    //Firebase Notifications
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        var token = ""
        for i in 0..<deviceToken.count {
            token = token + String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        print("Registration succeeded! Token: ", token)
        Messaging.messaging().apnsToken = deviceToken
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed! Error: \(error)")
    }
    
    // Firebase notification received
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        
        // custom code to handle push while app is in the foreground
        print("Handle push from foreground\(notification.request.content.userInfo)")
        
        let dict = notification.request.content.userInfo["aps"] as! NSDictionary
        let d : [String : Any] = dict["alert"] as! [String : Any]
        let body : String = d["body"] as! String
        let title : String = d["title"] as! String
        print("Title:\(title) + body:\(body)")
        guard let backgroundID = notification.request.content.userInfo[AnyHashable("gcm.notification.threadIdentifier")] as? String else {
            return
        }
        print("CLASS ID: \(backgroundID)")
        self.backgroundLaunchClassID = backgroundID
        //self.showAlertAppDelegate(title: title,message:body,buttonTitle:"ok",window:self.window!)
        
        let banner = Banner(title: title, subtitle: body, image: #imageLiteral(resourceName: "MessageIcon"), backgroundColor: UIColor(red:40.00/255.0, green:170.0/255.0, blue:226/255.0, alpha:1.000))
        
        banner.show(duration: 3.0)
        //banner.didTapBlock = GoToClassVC(fromVC: currentVC, toClassID: self.backgroundLaunchClassID)
        
        banner.didTapBlock = {
            self.GoToClassVC(fromVC: UIApplication.shared.keyWindow!.visibleViewController()!, toClassID: self.backgroundLaunchClassID)
        }
        
    }
    
    @available(iOS 10.0, *)
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        didLaunchFromBackground = true
        
        print(response.notification.request.content.userInfo)
        print(response.notification.request.content.userInfo[AnyHashable("gcm.notification.threadIdentifier")])
        
        guard let backgroundID = response.notification.request.content.userInfo[AnyHashable("gcm.notification.threadIdentifier")] as? String else {
            return
        }
        
        self.backgroundLaunchClassID = backgroundID
        self.didLaunchFromBackground = true
        
        
    }
    
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        
        let currentBadgeNumber = application.applicationIconBadgeNumber
        application.applicationIconBadgeNumber = currentBadgeNumber + 1
        
        print("RECEIVED NOTIFICATION REMOTELY!!!")
        
        if(application.applicationState == UIApplicationState.inactive || application.applicationState == UIApplicationState.background) {
            //Launched from background
            didLaunchFromBackground = true
            print("LAUNCHED FROM BACKGROUND!!!")
            
        }
    }
    
    func showAlertAppDelegate(title: String,message : String,buttonTitle: String,window: UIWindow){
        let alert = UIAlertController(title: title, message: message, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: buttonTitle, style: UIAlertActionStyle.default, handler: nil))
        window.rootViewController?.present(alert, animated: false, completion: nil)
    }
    
    @available(iOS 10.0, *)
    public func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Recieved: \(remoteMessage)")
    }
    
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("no clue what this is")
    }
    
    // Firebase ended here
    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        if self.didLaunchFromBackground {
            print(self.backgroundLaunchClassID)
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    
}


extension UIWindow {
    
    func visibleViewController() -> UIViewController? {
        if let rootViewController: UIViewController = self.rootViewController {
            return UIWindow.getVisibleViewControllerFrom(vc: rootViewController)
        }
        return nil
    }
    
    class func getVisibleViewControllerFrom(vc:UIViewController) -> UIViewController {
        
        if vc.isKind(of:UINavigationController.self) {
            
            let navigationController = vc as! UINavigationController
            return UIWindow.getVisibleViewControllerFrom( vc: navigationController.viewControllers.first!)
            
        } else if vc.isKind(of:UITabBarController.self) {
            
            let tabBarController = vc as! UITabBarController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController.selectedViewController!)
            
        }else if vc.isKind(of:UIAlertController.self) {
            
            let tabBarController = vc as! UIAlertController
            return UIWindow.getVisibleViewControllerFrom(vc: tabBarController)
            
        } else {
            
            if let presentedViewController = vc.presentedViewController {
                if (presentedViewController.presentedViewController != nil){
                    return UIWindow.getVisibleViewControllerFrom(vc: presentedViewController.presentedViewController!)
                }else{
                    return UIViewController()
                }
                
            } else {
                
                return vc;
            }
        }
    }
}
