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
    var isStarted: Bool!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        isStarted = false
        startButton.setBackgroundImageNamed("Start")
        group.setBackgroundImageNamed("Time")
        group.startAnimatingWithImagesInRange(NSMakeRange(0, 101), duration: 1.2, repeatCount: 1)
        // Configure interface objects here.
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
            let countdown: NSTimeInterval = 25*60
            let date = NSDate(timeIntervalSinceNow: countdown)
            timer.setDate(date)
            timer.start()
            startButton.setBackgroundImageNamed("Stop")
        } else {
            timer.stop()
            startButton.setBackgroundImage(UIImage(named: "Start"))
        }
    }
}
