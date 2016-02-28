//
//  InterfaceController.swift
//  Pom WatchKit Extension
//
//  Created by Corinne Krych on 26/02/16.
//  Copyright © 2016 corinne. All rights reserved.
//

import WatchKit
import Foundation

// todo change with object model
//let interval: NSTimeInterval = 10//25*60

class InterfaceController: WKInterfaceController {

    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var startButtonGroup: WKInterfaceGroup!
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var timer: WKInterfaceTimer!
    var timerFire: NSTimer!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        startButtonGroup.setBackgroundImageNamed("Start")
        group.setBackgroundImageNamed("Time")
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
            startButtonGroup.setBackgroundImageNamed("Stop")
        } else {
            timer.stop()
            timerFire.invalidate()
            startButtonGroup.setBackgroundImageNamed("Start")
            currentActivity.stop()
            group.stopAnimating()
            group.setBackgroundImageNamed("Time0")
        }
    }
    
    func fire() {
        timer.stop()
        startButtonGroup.setBackgroundImageNamed("Start")
        let manager = ActivitiesManager.instance
        guard let currentActivity = manager.currentActivity else {return}
                print("FIRE: \(currentActivity.name)")
        currentActivity.stop()
        group.stopAnimating()
        group.setBackgroundImageNamed("Time0")
    }
}
