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

class InterfaceController: WKInterfaceController, WCSessionDelegate {

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
    }
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        loadSavedTasks()
        group.setBackgroundImageNamed("Time")
        display(ActivitiesManager.instance.currentActivity)
    }
    
    override func didAppear() {
        super.didAppear()
        guard let currentActivity = ActivitiesManager.instance.currentActivity else {return}
        if (currentActivity.isStarted() == true) {
            let imageRangeRemaining = (currentActivity.duration - (currentActivity.remainingTime ?? 0))*90/currentActivity.duration
            group.startAnimatingWithImagesInRange(NSMakeRange(Int(imageRangeRemaining), 90), duration: currentActivity.duration, repeatCount: 1)
        }
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
        session.sendMessage(applicationData, replyHandler: {(dict: [String : AnyObject]) -> Void in
            // handle reply from iPhone app here
            print("iOS APP KNOWS Watch \(dict)")
            }, errorHandler: {(error) -> Void in
                // catch any errors here
                print("OOPs... Watch \(error)")
        })
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
    
    func display(activity: TaskActivity?) {
        guard let activity = activity else {
        taskNameLabel.setText("NOTHING TO DO :)")
        timer.setHidden(true)
        totalTimeLabel.setHidden(true)
        startButtonImage.setHidden(true)
        return
        }
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
// MARK: Task Persistance
extension InterfaceController {
    private var savedTasksPath: String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docPath = paths.first! as NSString
        let doc = docPath.stringByAppendingPathComponent("SavedTasks")
        print("DOC::\(doc)")
        return doc
    }
    
    func loadSavedTasks() {
        if let data = NSData(contentsOfFile: savedTasksPath) {
            let savedTasks = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! [TaskActivity]
            ActivitiesManager.instance.activities = savedTasks
        } else {
            ActivitiesManager.instance.activities = []
        }
    }
    
    func saveTasks() {
        guard let activities = ActivitiesManager.instance.activities else {return}
        NSKeyedArchiver.archiveRootObject(activities, toFile: savedTasksPath)
    }
}