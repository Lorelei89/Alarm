//
//  Persistable.swift
//  AlarmClockMaxcode
//
//  Created by Sabina Buruiana on 3/14/17.
//  Copyright © 2017 Sabina Buruiana. All rights reserved.
//

import Foundation

protocol Persistable{
    var ud: UserDefaults {get}
    var persistKey : String {get}
    func persist()
    func unpersist()
}
