//
//  InterfaceController.swift
//  Pom WatchKit Extension
//
//  Created by Corinne Krych on 26/02/16.
//  Copyright © 2016 corinne. All rights reserved.
//

import WatchKit
import Foundation

class InterfaceController: WKInterfaceController {

    @IBOutlet var taskNameLabel: WKInterfaceLabel!
    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var startButtonImage: WKInterfaceImage!
    @IBOutlet var totalTimeLabel: WKInterfaceLabel!
    var timerFire: NSTimer!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        group.setBackgroundImageNamed("Time")
        display(ActivitiesManager.instance.currentActivity)
    }

    override func willActivate() {
        super.willActivate()
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
            group.startAnimatingWithImagesInRange(NSMakeRange(0, 101), duration: currentActivity.duration, repeatCount: 1)
            startButtonImage.setHidden(true)
            timer.setHidden(false)
            display(ActivitiesManager.instance.currentActivity)
        } else {
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
    }
    
    func display(activity: Activity?) {
        if let duration = activity?.duration {
            if duration < 60 {
                totalTimeLabel.setText("\(duration) sec")
            } else {
                let durationInMin = duration/60
                totalTimeLabel.setText("\(durationInMin) min")
            }
        }
        if let name = activity?.name {
            taskNameLabel.setText(name)
        }
    }
}
