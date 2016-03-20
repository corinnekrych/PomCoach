//
//  InterfaceController.swift
//  Pom WatchKit Extension
//
//  Created by Corinne Krych on 26/02/16.
//  Copyright © 2016 corinne. All rights reserved.
//

import WatchKit
import Foundation
import WatchConnectivity

class InterfaceController: WKInterfaceController {

    @IBOutlet var taskNameLabel: WKInterfaceLabel!
    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var startButtonImage: WKInterfaceImage!
    @IBOutlet var totalTimeLabel: WKInterfaceLabel!
    var timerFire: NSTimer!
    var session: WCSession!
    
    override func willActivate() {
        super.willActivate()
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self
            session.activateSession()
        }
        guard let currentActivity = ActivitiesManager.instance.currentActivity else {return}
        if (currentActivity.isStarted() == true) {
            let imageRangeRemaining = (currentActivity.duration - (currentActivity.remainingTime ?? 0))*90/currentActivity.duration
            group.startAnimatingWithImagesInRange(NSMakeRange(Int(imageRangeRemaining), 90), duration: currentActivity.duration, repeatCount: 1)
        }
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        group.setBackgroundImageNamed("Time")
        display(ActivitiesManager.instance.currentActivity)
    }
    
    override func didAppear() {
        super.didAppear()
    }

    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @IBAction func stop() {
        print("::::::STOP")
        let manager = ActivitiesManager.instance
        guard let currentActivity = manager.currentActivity else {return}
        
        timer.stop()
        timerFire.invalidate()
        startButtonImage.setHidden(false)
        timer.setHidden(true)
        currentActivity.stop()
        group.stopAnimating()
        // init for next task
        group.setBackgroundImageNamed("Time0")
        display(ActivitiesManager.instance.currentActivity)
    }

    @IBAction func onStartButton() {
        print("onStartButton")
        let manager = ActivitiesManager.instance
        guard let currentActivity = manager.currentActivity else {return}
        if !currentActivity.isStarted() {
            print("currentActivitied:\(currentActivity.name):")
            let duration = NSDate(timeIntervalSinceNow: currentActivity.duration)
            timer.setDate(duration)
            timer.start()
            timerFire = NSTimer.scheduledTimerWithTimeInterval(currentActivity.duration, target: self, selector: "fire", userInfo: nil, repeats: false)
            currentActivity.start()
            group.setBackgroundImageNamed("Time")
            group.startAnimatingWithImagesInRange(NSMakeRange(0, 90), duration: currentActivity.duration, repeatCount: 1)
            startButtonImage.setHidden(true)
            timer.setHidden(false)
            display(ActivitiesManager.instance.currentActivity)
            sendStartTimer(currentActivity.name, startDate: currentActivity.startDate, endDate: currentActivity.endDate)
        }
    }
    
    func sendStartTimer(taskName: String, startDate: NSDate?, endDate: NSDate?) {
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        var startDateString: String
        if let startDate = startDate {
            startDateString = dateFormatter.stringFromDate(startDate)
        } else {
            startDateString = ""
        }
        var endDateString: String
        if let endDate = endDate {
            endDateString = dateFormatter.stringFromDate(endDate)
        } else {
            endDateString = ""
        }
        let applicationData = ["task": taskName, "start": startDateString, "end": endDateString]
        print("SEND from watch \(applicationData)")
        if session.reachable {
            session.sendMessage(applicationData, replyHandler: {(dict: [String : AnyObject]) -> Void in
                // handle reply from iPhone app here
                print("iOS APP KNOWS Watch \(dict)")
                }, errorHandler: {(error) -> Void in
                    // catch any errors here
                    print("OOPs... Watch \(error)")
            })
        } else {
            alertiOSAppLocked()
            print("SESSION REACHable\(session.reachable)")
        }
    }
    
    func alertiOSAppLocked() {
        let action = WKAlertAction(title: "Ok", style: .Default) {}
        presentAlertControllerWithTitle("PomCoach", message: "Looks like your phone is locked. Unlock!", preferredStyle: .ActionSheet, actions: [action])
    }
    
    func fire() {
        timer.stop()
        startButtonImage.setHidden(false)
        timer.setHidden(true)
        let manager = ActivitiesManager.instance
        guard let currentActivity = manager.currentActivity else {return}
        print("FIRE: \(currentActivity.name)")
        currentActivity.stop()
        group.stopAnimating()
        // init for next
        group.setBackgroundImageNamed("Time0")
        display(ActivitiesManager.instance.currentActivity)
        sendStartTimer(currentActivity.name, startDate: currentActivity.startDate, endDate: currentActivity.endDate)
    }
    
    func display(activity: Activity?) {
        guard let activity = activity else {
        taskNameLabel.setText("NOTHING TO DO :)")
        timer.setHidden(true)
        totalTimeLabel.setHidden(true)
        startButtonImage.setHidden(true)
        return
        }
        startButtonImage.setHidden(false)
        let duration = activity.duration
        if duration < 60 {
            totalTimeLabel.setText("\(duration) sec")
        } else {
            let durationInMin = duration/60
            totalTimeLabel.setText("\(durationInMin) min")
        }
        taskNameLabel.setText(activity.name)
    }
}
// MARK: WCSessionDelegate
extension InterfaceController: WCSessionDelegate {
    func session(session: WCSession, didReceiveApplicationContext applicationContext: [String : AnyObject]) {
        dispatch_async(dispatch_get_main_queue()) {
            print("Received application context \(applicationContext)")
            if let tasks = applicationContext["activities"] as? [[String : AnyObject]] {
                let activities = tasks.map({ (task: [String : AnyObject]) -> TaskActivity in
                    if let name = task["name"] as? String, let duration = task["duration"] as? Double, let type = task["type"] as? Int {
                        return TaskActivity(name: name,
                            duration: NSTimeInterval(duration),
                            startDate: nil, endDate: nil,
                            type: ActivityType(rawValue: type)!,
                            manager: ActivitiesManager.instance)
                    }
                    return TaskActivity(name: "TODO", duration: NSTimeInterval(10), manager: ActivitiesManager.instance)
            })
            ActivitiesManager.instance.remainingActivities = activities
            self.display(ActivitiesManager.instance.currentActivity)
            } else if let task = applicationContext["task"] as? [String : AnyObject] {
                if let name = task["name"] as? String,
                    let duration = task["duration"] as? Double,
                    let type = task["type"] as? Int,
                    let startDate = task["startDate"] as? Double,
                    let endDate = task["endDate"] as? Double {
                    
                        // TODO when task started from app no animation displayed
                        
                    let taskObject = TaskActivity(name: name,
                        duration: NSTimeInterval(duration),
                        startDate: NSDate(timeIntervalSinceReferenceDate: startDate),
                        endDate: NSDate(timeIntervalSinceReferenceDate: endDate),
                        type: ActivityType(rawValue: type)!,
                        manager: ActivitiesManager.instance)
 
                    let duration = NSDate(timeIntervalSinceNow: taskObject.duration)
                    self.timer.setDate(duration)
                    self.timer.start()
                    self.timerFire = NSTimer.scheduledTimerWithTimeInterval(taskObject.duration, target: self, selector: "fire", userInfo: nil, repeats: false)
                    self.display(taskObject)
                }
            }
        }
    }
}
