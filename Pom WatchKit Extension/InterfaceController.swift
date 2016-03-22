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
    var actvitiesMgr: ActivitiesManager!
    
    override func willActivate() {
        super.willActivate()
        
        guard let currentActivity = actvitiesMgr.currentActivity else {return}
        display(currentActivity)
        
        if let _ = currentActivity.startDate where currentActivity.endDate == nil {
            replayAnimation(currentActivity)
        }
    }
    
    func activitiesUpdated(note: NSNotification) { // insert new task, or task completed on ios app
        group.setBackgroundImageNamed("Time0")
        self.display(actvitiesMgr.currentActivity)
    }
    
    func activityStarted(note: NSNotification) { // task started from ios app
        if let userInfo = note.object, let taskFromNotification = userInfo["task"] as? TaskActivity, let current = actvitiesMgr.currentActivity where taskFromNotification.name == current.name {
            replayAnimation(taskFromNotification)
        }
    }
    
    func replayAnimation(task: TaskActivity) {
        if let startDate = task.startDate  {
            self.group.setBackgroundImageNamed("Time")
            let timeElapsed = NSDate().timeIntervalSinceDate(startDate)
            let imageRangeRemaining = (timeElapsed)*90/task.duration
            self.group.startAnimatingWithImagesInRange(NSMakeRange(Int(imageRangeRemaining), 90), duration: task.duration - timeElapsed, repeatCount: 1)
            self.display(task)
        }
    }

    override func awakeWithContext(context: AnyObject?) {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("activitiesUpdated:"), name: "ActivitiesUpdated", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("activityStarted:"), name: "CurrentActivityStarted", object: nil)

        super.awakeWithContext(context)
        group.setBackgroundImageNamed("Time")
        
        let delegate = WKExtension.sharedExtension().delegate as! ExtensionDelegate
        session = delegate.session
        actvitiesMgr = delegate.actvitiesMgr
        display(actvitiesMgr.currentActivity)
    }
    
    override func didAppear() {
        super.didAppear()
    }
    
    override func didDeactivate() {
        super.didDeactivate()
    }
    
    @IBAction func stop() {
        print("::::::STOP")
        guard let currentActivity = actvitiesMgr.currentActivity else {return}
        
        timer.stop()
        timerFire.invalidate()
        startButtonImage.setHidden(false)
        timer.setHidden(true)
        currentActivity.stop()
        group.stopAnimating()
        // init for next task
        group.setBackgroundImageNamed("Time0")
        display(actvitiesMgr.currentActivity)
    }
    
    @IBAction func onStartButton() {
        print("onStartButton")
        guard let currentActivity = actvitiesMgr.currentActivity else {return}
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
            display(actvitiesMgr.currentActivity)
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
        guard let currentActivity = actvitiesMgr.currentActivity else {return}
        print("FIRE: \(currentActivity.name)")
        currentActivity.stop()
        group.stopAnimating()
        // init for next
        group.setBackgroundImageNamed("Time0")
        display(actvitiesMgr.currentActivity)
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