//
//  AlarmModel.swift
//  AlarmClockMaxcode
//
//  Created by Sabina Buruiana on 3/14/17.
//  Copyright © 2017 Sabina Buruiana. All rights reserved.
//

import Foundation

struct Alarm  {
    var id: String = ""
    var hour: Int = 0
    var minutes: Int = 0
    var label: String = "Alarm"
    var enabled: Bool = false
    var UUID :String = ""
    var token:String = "4b412813-0bc1-49a3-bd20-97751d28e10b"
    var date:Date = Date()
    
     /* CONSTRUCTORS */
    
    init(){}
    
    init(hour:Int, minutes:Int, label:String , enabled:Bool, token:String){
        self.hour = hour
        self.label = label
        self.minutes = minutes
        self.enabled = enabled
        self.token = token
    }
    
    /* ACCESS CONTROL METHODS */
    
    mutating func setHour (_ etaHour: Int) {
        self.hour = etaHour
    }
    mutating func setMinutes (_ etaMinutes: Int) {
        self.minutes = etaMinutes
    }
    
    mutating func setToken (_ newToken: String) {
        self.token = newToken
    }
    
    mutating func setLabel (_ newLabel: String) {
        self.label = newLabel
    }
    
    mutating func setEnable (_ newEnabled: Bool) {
        self.enabled = newEnabled
    }
    
    mutating func setUUID ( _ newUUID :String) {
        self.UUID =  newUUID
    }
    mutating func setDate(_newDate:Date) {
        self.date = _newDate
    }
    
    
    
     /* SERIALIZATION */
    
    mutating func fromDictionary (_ dict: NSDictionary) {
        self.id = dict["id"] as! String
        self.label = dict["label"] as! String
        self.hour = dict["hour"] as! Int
        self.minutes = dict["minutes"] as! Int
        self.enabled = dict["enabled"] as! Bool
        self.token = dict["token"] as! String
        
    }
    
    func toDictionary () -> NSDictionary {
        let dict: NSDictionary = [
            "id": self.id,
            "label": self.label,
            "hour": self.hour,
            "minutes": self.minutes,
            "enabled": self.enabled,
            "token": self.token
        ]
        return dict
    }
    
    
    /* METHODS */
    
    mutating func turnOn () {
        self.enabled = true
    }
    
    mutating func turnOff () {
        self.enabled = false
    }
    
    func calculateDate() -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let time = formatter.date(from: "\(self.hour):\(self.minutes)")!
        return time
    }
    
    func getDateString () -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeStyle = DateFormatter.Style.short
        let  date  = calculateDate()
        return dateFormatter.string(from: date)
    }
}





