//
//  AppDelegate.swift
//  AlarmClockMaxcode
//
//  Created by Sabina Buruiana on 3/14/17.
//  Copyright © 2017 Sabina Buruiana. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    let ALARMS_KEY = "alarmItems"
    
    let GET_URL = "https://smart-alarm-server.herokuapp.com/user_history_records.json"
    let POST_URL = "https://smart-alarm-server.herokuapp.com/user_history_records.json"
    let DELETE_URL = "https://smart-alarm-server.herokuapp.com/user_history_records.json"
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
        
        UIApplication.shared.setMinimumBackgroundFetchInterval(UIApplicationBackgroundFetchIntervalMinimum)
        
        /* REGISTER NOTIFICATION ACTIONS */
        
        // AWAKE ACTION
        let awakeAction = UIMutableUserNotificationAction()
        awakeAction.identifier = "AWAKE_ACTION" // the unique identifier for this action
        awakeAction.title = "Ok, I'm up!" // title for the action button
        awakeAction.activationMode = .background // UIUserNotificationActivationMode.Background - don't bring app to foreground
        awakeAction.isAuthenticationRequired = false // don't require unlocking before performing action
        awakeAction.isDestructive = true // display action in red
        
        // ALARM CATEGORY
        let alarmCategory = UIMutableUserNotificationCategory()
        alarmCategory.identifier = "ALARM_CATEGORY"
        alarmCategory.setActions([awakeAction], for: .default)
        alarmCategory.setActions([awakeAction], for: .minimal)
        
        // GET ACTION
        let getAction = UIMutableUserNotificationAction()
        getAction.identifier = "GET_ACTION"
        getAction.title = "Yes! I've arrived."
        getAction.activationMode = .background
        getAction.isAuthenticationRequired = false
        getAction.isDestructive = false
        
        // POST ACTION
        let postAction = UIMutableUserNotificationAction()
        postAction.identifier = "POST_ACTION"
        postAction.title = "No, I'm late"
        postAction.activationMode = .background
        postAction.isAuthenticationRequired = false
        postAction.isDestructive = true
        
        // DELETE ACTION
        let deleteAction = UIMutableUserNotificationAction()
        deleteAction.identifier = "DELETE_ACTION"
        deleteAction.title = "No, I'm late"
        deleteAction.activationMode = .background
        deleteAction.isAuthenticationRequired = false
        deleteAction.isDestructive = true
        
        // FOLLOWUP CATEGORY
        let followupCategory = UIMutableUserNotificationCategory()
        followupCategory.identifier = "FOLLOWUP_CATEGORY"
        followupCategory.setActions([getAction, postAction,deleteAction], for: .default)
        followupCategory.setActions([getAction, postAction,deleteAction], for: .minimal)
        
        // REGISTER NOTIFICATIONS
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: [alarmCategory, followupCategory]))
        return true
    }
    
    /* HANDLE NOTIFICATION ACTIONS */
    
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        switch (identifier!) {
        case "AWAKE_ACTION":
            print("APP DELEGATE: AWAKE_ACTION")
            break
        case "GET_ACTION":
            print("APP DELEGATE: ARRIVE_ACTION")
            
            // Format NSDate before POST
            let arrivalTime = notification.fireDate!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let formattedArrival = dateFormatter.string(from: arrivalTime)
            
            let dataDictionary: NSDictionary = [
                "uuid": UIDevice.current.identifierForVendor!.uuidString,
                "arrival": formattedArrival,
                "on_time": true
            ]
            
            let http = HTTP()
            let dataJSON = http.toJSON(dataDictionary)
            http.GET(GET_URL, requestJSON: dataJSON!, postComplete: { (success: Bool, msg: String) -> () in
                if success {
                    print("HTTP REQUEST SUCCESS")
                    print(msg)
                } else {
                    print("HTTP REQUEST FAILED")
                    print(msg)
                }
            })
            break
        case "POST_ACTION":
            print("APP DELEGATE: PSOT_ACTION")
            
            // Format NSDate before POST
            let arrivalTime = notification.fireDate!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let formattedArrival = dateFormatter.string(from: arrivalTime)
            
            let dataDictionary: NSDictionary = [
                "uuid": UIDevice.current.identifierForVendor!.uuidString,
                "arrival": formattedArrival,
                "on_time": false
            ]
            
            let http = HTTP()
            let dataJSON = http.toJSON(dataDictionary)
            http.POST(POST_URL, requestJSON: dataJSON!, postComplete: { (success: Bool, msg: String) -> () in
                if success {
                    print("HTTP REQUEST SUCCESS")
                    print(msg)
                } else {
                    print("HTTP REQUEST FAILED")
                    print(msg)
                }
            })
            break
            
        case "DELETE_ACTION":
            print("APP DELEGATE: DELETE_ACTION")
            
            // Format NSDate before POST
            let arrivalTime = notification.fireDate!
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let formattedArrival = dateFormatter.string(from: arrivalTime)
            
            let dataDictionary: NSDictionary = [
                "uuid": UIDevice.current.identifierForVendor!.uuidString,
                "arrival": formattedArrival,
                "on_time": false
            ]
            
            let http = HTTP()
            let dataJSON = http.toJSON(dataDictionary)
            http.DELETE(DELETE_URL, requestJSON: dataJSON!, postComplete: { (success: Bool, msg: String) -> () in
                if success {
                    print("HTTP REQUEST SUCCESS")
                    print(msg)
                } else {
                    print("HTTP REQUEST FAILED")
                    print(msg)
                }
            })
            break
        default:
            print("ERROR HANDLING NOTIFICATION ACTIONS")
        }
        completionHandler() // per developer documentation, app will terminate if we fail to call this
    }
    
    /* BACKGROUND FETCH */
    
    func application(_ application: UIApplication, performFetchWithCompletionHandler completionHandler:
        @escaping (UIBackgroundFetchResult) -> Void) {
        print("Fetch called.")
        if let navController = window?.rootViewController as! UINavigationController? {
            let viewControllers = navController.viewControllers as [UIViewController]
            for viewController in viewControllers {
                if let atvc = viewController as? MainAlarmViewController {
                    atvc.fetch({
                        atvc.backgroundFetchDone()
                        completionHandler(.newData)
                    })
                }
            }
        }
    }

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
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

