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
let interval: NSTimeInterval = 10//25*60

class InterfaceController: WKInterfaceController {

    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var startButtonGroup: WKInterfaceGroup!
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var timer: WKInterfaceTimer!
    var isStarted: Bool!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        isStarted = false
        startButtonGroup.setBackgroundImageNamed("Start")
        group.setBackgroundImageNamed("Time")
    }

    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }

    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

    @IBAction func onStartButton() {
        print("onStartButton")
        isStarted = !isStarted
        if isStarted == true {
            let countdown: NSTimeInterval = interval
            let date = NSDate(timeIntervalSinceNow: countdown)
            timer.setDate(date)
            timer.start()
            group.startAnimatingWithImagesInRange(NSMakeRange(0, 101), duration: interval, repeatCount: 1)
            startButtonGroup.setBackgroundImageNamed("Stop")
        } else {
            timer.stop()
            startButtonGroup.setBackgroundImageNamed("Start")
            group.stopAnimating()
            //group.setBackgroundImageNamed("Time10")
        }
    }
}
