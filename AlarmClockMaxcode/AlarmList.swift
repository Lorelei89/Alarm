//
//  AlarmList.swift
//  AlarmClockMaxcode
//
//  Created by Sabina Buruiana on 3/21/17.
//  Copyright © 2017 Sabina Buruiana. All rights reserved.
//

import Foundation


import Foundation
import UIKit
import MapKit

class AlarmList {
    
    fileprivate let ALARMS_KEY = "alarmItems"
    
    /* SINGLETON CONSTRUCTOR */
    
    class var sharedInstance: AlarmList {
        struct Static {
            static let instance: AlarmList = AlarmList()
        }
        return Static.instance
    }
    
    /* ALARM FUNCTIONS */
    
    func allAlarms () -> [Alarm] {
        let alarmDictionary = UserDefaults.standard.dictionary(forKey: ALARMS_KEY) ?? Dictionary()
        var alarmItems:[Alarm] = []
        
        for data in alarmDictionary.values {
            let dict = data as! NSDictionary
            var alarm = Alarm()
            alarm.fromDictionary(dict)
            alarmItems.append(alarm)
        }
        return alarmItems
    }
    
    func addAlarm (_ newAlarm: Alarm) {
        // Create persistent dictionary of data
        var alarmDictionary = UserDefaults.standard.dictionary(forKey: ALARMS_KEY) ?? Dictionary()
        
        // Copy alarm object into persistent data
        alarmDictionary[newAlarm.token] = newAlarm.toDictionary()
        
        // Save or overwrite data
        UserDefaults.standard.set(alarmDictionary, forKey: ALARMS_KEY)
        
        // Schedule notifications
        scheduleNotification(newAlarm, category: "ALARM_CATEGORY")
        scheduleNotification(newAlarm, category: "FOLLOWUP_CATEGORY")
    }
    
    func removeAlarm (_ alarmToRemove: Alarm) {
        // Remove alarm notifications
        cancelNotification(alarmToRemove, category: "ALARM_CATEGORY")
        cancelNotification(alarmToRemove, category: "FOLLOWUP_CATEGORY")
        
        // Remove alarm from persistent data
        if var alarmDictionary = UserDefaults.standard.dictionary(forKey: ALARMS_KEY) {
            alarmDictionary.removeValue(forKey: alarmToRemove.token as String)
            UserDefaults.standard.set(alarmDictionary, forKey: ALARMS_KEY)        }
    }
    
    func updateAlarm (alarmToUpdate: Alarm) {
        // Remove old alarm
        var alarmToUpdate = alarmToUpdate
        removeAlarm(alarmToUpdate)
        
        // Create new unique IDs
        let newUUID = UUID().uuidString
        
        // Associate with the alarm by updating IDs
        alarmToUpdate.setUUID(newUUID)

        
        // Reschedule new alarm
        addAlarm(alarmToUpdate)
    }
    
    /* NOTIFICATION FUNCTIONS */
    
    func scheduleNotification (_ alarm: Alarm, category: String) {
        let notification = UILocalNotification()
        notification.category = category
        notification.repeatInterval = NSCalendar.Unit.day
        
        switch category {
        case "ALARM_CATEGORY":
            notification.userInfo = ["UUID": alarm.UUID]
            notification.alertBody = "Time to wake up!"
            notification.fireDate = alarm.calculateDate()
            break
        case "FOLLOWUP_CATEGORY":
            notification.userInfo = ["UUID": alarm.id]
            notification.alertBody = "Did you arrive yet?"
            notification.fireDate = alarm.calculateDate()
            notification.soundName = UILocalNotificationDefaultSoundName
            break
        default:
            print("ERROR SCHEDULING NOTIFICATION")
            return
        }
        
        // For debugging purposes
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.short
        dateFormatter.timeStyle = DateFormatter.Style.short
        print("ALARM SCHEDULED FOR :", dateFormatter.string(from: notification.fireDate!))
        
        UIApplication.shared.scheduleLocalNotification(notification)
    }
    
    func cancelNotification (_ alarm: Alarm, category: String) {
        var ID: String
        switch category {
        case "ALARM_CATEGORY":
            ID = alarm.UUID
            break
        case "FOLLOWUP_CATEGORY":
            ID = alarm.id
            break
        default:
            print("ERROR CANCELLING NOTIFICATION")
            return
        }
        
        for event in UIApplication.shared.scheduledLocalNotifications! {
            let notification = event as UILocalNotification
            if (notification.userInfo!["UUID"] as! String == ID) {
                UIApplication.shared.cancelLocalNotification(notification)
                break
            }
        }
    }
}
