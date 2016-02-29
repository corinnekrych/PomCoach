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

    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var startButtonImage: WKInterfaceImage!
    @IBOutlet var totalTimeLabel: WKInterfaceLabel!
    var timerFire: NSTimer!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        group.setBackgroundImageNamed("Time")
        formatTotalTime(ActivitiesManager.instance.currentActivity)
    }

    override func willActivate() {
        super.willActivate()
    }

    override func didDeactivate() {
        super.didDeactivate()
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
            formatTotalTime(ActivitiesManager.instance.currentActivity)
        } else {
            timer.stop()
            timerFire.invalidate()
            startButtonImage.setHidden(false)
            timer.setHidden(true)
            currentActivity.stopAndGoNext()
            group.stopAnimating()
            // init for next task
            group.setBackgroundImageNamed("Time0")
            formatTotalTime(ActivitiesManager.instance.currentActivity)
        }
    }
    
    func fire() {
        timer.stop()
        startButtonImage.setHidden(false)
        timer.setHidden(true)
        let manager = ActivitiesManager.instance
        guard let currentActivity = manager.currentActivity else {return}
        print("FIRE: \(currentActivity.name)")
        currentActivity.stopAndGoNext()
        group.stopAnimating()
        // init for next
        group.setBackgroundImageNamed("Time0")
        formatTotalTime(ActivitiesManager.instance.currentActivity)
    }
    
    func formatTotalTime(activity: Activity?) {
        if let duration = activity?.duration {
            totalTimeLabel.setText("\(duration) sec")
        }
    }
}
