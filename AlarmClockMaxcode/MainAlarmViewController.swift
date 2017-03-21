//
//  MainAlarmViewController.swift
//  AlarmClockMaxcode
//
//  Created by Sabina Buruiana on 3/14/17.
//  Copyright © 2017 Sabina Buruiana. All rights reserved.
//

import Foundation
import UIKit
import MapKit


class MainAlarmViewController:  UITableViewController, CLLocationManagerDelegate {
    
    var alarms:[Alarm] = []
    let locationManager = CLLocationManager()
    let noDataLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.clearsSelectionOnViewWillAppear = true
        
        // Configure data source
        alarms = AlarmList.sharedInstance.allAlarms()
        
        // Check if empty
        noDataLabel.text = "No alarms"
        noDataLabel.font = UIFont(name: "Lato", size: 20)
        noDataLabel.textAlignment = NSTextAlignment.center
        noDataLabel.textColor = UIColor(hue: 0.5833, saturation: 0.44, brightness: 0.36, alpha: 1.0)
        noDataLabel.alpha = 0.0
        self.tableView.backgroundView = noDataLabel
        checkScheduledAlarms()
        
        // Enable edit button
        self.navigationItem.leftBarButtonItem = self.editButtonItem
        
        // Manage selection during editing mode
        self.tableView.allowsSelection = false
        self.tableView.allowsSelectionDuringEditing = true
        
        // Set up the CLLocationManager, adjust location updates here
        self.locationManager.delegate = self
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.startUpdatingLocation()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer
        self.locationManager.distanceFilter = kCLLocationAccuracyKilometer
    }
    
    override func viewWillAppear(_ animated: Bool) {
        checkScheduledAlarms()
    }
    
    /* HANDLE EMPTY DATA SOURCE */
    
    func checkScheduledAlarms () {
        UIView.animate(withDuration: 0.25, animations: {
            if self.alarms.count == 0 {
                self.noDataLabel.alpha = 1.0
            } else {
                self.noDataLabel.alpha = 0.0
            }
        })
    }
    
    /* CONFIGURE ROWS AND SECTIONS */
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return alarms.count
    }
    
    /* CONFIGURE CELL */
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "alarmCell", for: indexPath) as! AlarmTableViewCell
        cell.alarmTime.text! = alarms[indexPath.row].getWakeupString()
        cell.alarmDestination!.text = alarms[indexPath.row].destination.name
        cell.alarmToggle.tag = indexPath.row
        cell.alarmToggle.addTarget(self, action: #selector(AlarmTableViewController.toggleAlarm(_:)), for: UIControlEvents.valueChanged)
        cell.accessoryView = cell.alarmToggle
        return cell
    }
    
    /* TOGGLE ALARM STATE */
    
    func toggleAlarm (_ switchState: UISwitch) {
        let index = switchState.tag
        
        if switchState.isOn {
            alarms[index].turnOn()
            AlarmList.sharedInstance.scheduleNotification(alarms[index], category: "ALARM_CATEGORY")
            AlarmList.sharedInstance.scheduleNotification(alarms[index], category: "FOLLOWUP_CATEGORY")
        } else {
            alarms[index].turnOff()
            AlarmList.sharedInstance.cancelNotification(alarms[index], category: "ALARM_CATEGORY")
            AlarmList.sharedInstance.cancelNotification(alarms[index], category: "FOLLOWUP_CATEGORY")
        }
    }
    
    /* ENABLE EDITING */
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            AlarmList.sharedInstance.removeAlarm(alarms[indexPath.row]) // remove from persistent data
            alarms.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // Update tags for alarm state
            var t = 0
            for cell in tableView.visibleCells as! [AlarmTableViewCell] {
                cell.alarmToggle.tag = t++
            }
            
            checkScheduledAlarms()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        if (self.isEditing == true) {
            performSegue(withIdentifier: "editAlarm", sender: self)
        }
    }
    
    /* NAVIGATION */
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let navVC = segue.destination as! UINavigationController
        let detailTVC = navVC.viewControllers.first as! DetailTableViewController
        
        if (segue.identifier == "editAlarm") {
            let indexPath = self.tableView.indexPathForSelectedRow!
            detailTVC.alarm = alarms[indexPath.row].copy()
            detailTVC.title = "Edit Alarm"
        } else {
            detailTVC.title = "Add Alarm"
        }
    }
    
    /* UNWIND SEGUES */
    
    @IBAction func saveAlarm (_ segue:UIStoryboardSegue) {
        let detailTVC = segue.source as! AlarmAddEditViewController
        let newAlarm = detailTVC.alarmModel
        
        if (self.tableView.isEditing == false) {
            // TODO: FIX THIS!!!
            if (newAlarm.destination.name == "") {
                return
            }
            
            let indexPath = IndexPath(row: alarms.count, section: 0)
            alarms.append(newAlarm)
            AlarmList.sharedInstance.addAlarm(newAlarm)
            
            self.tableView.beginUpdates()
            self.tableView.insertRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
        } else {
            let indexPath = self.tableView.indexPathForSelectedRow!
            self.alarms[indexPath.row] = detailTVC.alarmModel
            AlarmList.sharedInstance.updateAlarm(alarmToUpdate: self.alarms[indexPath.row])
            
            self.tableView.beginUpdates()
            self.tableView.reloadRows(at: [indexPath], with: .fade)
            self.tableView.endUpdates()
        }
    }
    
    @IBAction func cancelAlarm (_ segue:UIStoryboardSegue) {
        // Do nothing!
    }
    
    /* BACKGROUND REFRESH */
    
    // TODO: FIX!!!
    
//    func locationManager(_ manager: CLLocationManager, didUpdateToLocation newLocation: CLLocation, fromLocation oldLocation: CLLocation) {
//        //for alarm in self.alarms {
//        for index in 0 ..< alarms.count {
//            let alarm = alarms[index]
//            
//            if alarm.isActive {
//                let request = MKDirectionsRequest()
//                request.source = MKMapItem(placemark: MKPlacemark(coordinate: newLocation.coordinate, addressDictionary: nil))
//                request.destination = alarm.destination.toMKMapItem()
//                
//                if alarm.transportation == .Transit {
//                    request.transportType = .transit
//                } else {
//                    request.transportType = .automobile
//                }
//                
//                request.requestsAlternateRoutes = false
//                let direction = MKDirections(request: request)
//                direction.calculateETA(completionHandler: {
//                    (response, err) -> Void in
//                    if response == nil {
//                        print("Inside didUpdateToLocation: Failed to get routes.")
//                        self.tableView.reloadData()
//                        return
//                    }
//                    let minutes = (response?.expectedTravelTime)! / 60.0
//                    alarm.setETA(Int(round(minutes)))
//                    print("Inside didUpdateToLocation: \(minutes)")
//                    print("The estimated time is: \(alarm.getWakeupString())")
//                    AlarmList.sharedInstance.updateAlarm(alarm)
//                    self.tableView.reloadData()
//                })
//            }
//        }
//    }
//    
    func backgroundFetchDone() {
        print("Fetch completion handler called.")
        //locationManager.stopUpdatingLocation()
    }
    
    func fetch(_ completionHandler: () -> Void) {
        for index in 0 ..< alarms.count {
            var alarm = alarms[index]
            
            if alarm.isActive {
                let request = MKDirectionsRequest()
                let location = locationManager.location
                request.source = MKMapItem(placemark: MKPlacemark(coordinate: (location?.coordinate)!, addressDictionary: nil))
                request.destination = alarm.destination.toMKMapItem()
                
                if alarm.transportation == .Transit {
                    request.transportType = .transit
                } else {
                    request.transportType = .automobile
                }
                
                request.requestsAlternateRoutes = false
                let direction = MKDirections(request: request)
                direction.calculateETA(completionHandler: {
                    (response, err) -> Void in
                    if response == nil {
                        print("Inside fetch: Failed to get routes.")
                        self.tableView.reloadData()
                        return
                    }
                    let hour = (response?.expectedTravelTime)!
                    let minutes = (response?.expectedTravelTime)! / 60.0
                    let newLabel = minutes + hour
                    alarm.setLabel(newLabel)
                    print("Inside fetch: \(minutes)")
                    print("The estimated time is: \(alarm.getDateString())")
                    AlarmList.sharedInstance.updateAlarm(alarm)
                    self.tableView.reloadData()
                })
            }
        }
        //Call completionHandler
        completionHandler()
    }
    
}
