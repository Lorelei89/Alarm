//
//  AlarmSchedulerDelegate.swift
//  AlarmClockMaxcode
//
//  Created by Sabina Buruiana on 3/14/17.
//  Copyright © 2017 Sabina Buruiana. All rights reserved.
//

import Foundation

protocol AlarmSchedulerDelegate {
    func setNotificationWithDate(_ date: Date, onWeekdaysForNotify:[Int], snoozeEnabled: Bool, onSnooze:Bool, soundName: String, index: Int)
    //helper
    func setNotificationForSnooze(snoozeMinute: Int, soundName: String, index: Int)
    func setupNotificationSettings()
    func reSchedule()
}

