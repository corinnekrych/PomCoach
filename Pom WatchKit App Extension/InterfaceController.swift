//
//  InterfaceController.swift
//  Pom WatchKit App Extension
//
//  Created by Corinne Krych on 03/04/16.
//  Copyright © 2016 corinne. All rights reserved.
//

import WatchKit
import Foundation


class InterfaceController: WKInterfaceController {

    @IBOutlet var group: WKInterfaceGroup!
    @IBOutlet var taskNameLabel: WKInterfaceLabel!
    @IBOutlet var startButton: WKInterfaceButton!
    @IBOutlet var timer: WKInterfaceTimer!
    @IBOutlet var startButtonImage: WKInterfaceImage!
    var timerFire: NSTimer!
    
    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        display(TasksManager.instance.currentTask)
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
        guard let currentTask = TasksManager.instance.currentTask else {return}
        if !currentTask.isStarted() {
            print("currentActivitied:\(currentTask.name):")
            let duration = NSDate(timeIntervalSinceNow: currentTask.duration)
            timer.setDate(duration)
            timer.start()
            timerFire = NSTimer.scheduledTimerWithTimeInterval(currentTask.duration,
                target: self, selector: "fire", userInfo: nil, repeats: false)
            currentTask.start()
            group.setBackgroundImageNamed("Time")
            group.startAnimatingWithImagesInRange(NSMakeRange(0, 90), duration: currentTask.duration, repeatCount: 1)
            startButtonImage.setHidden(true)
            timer.setHidden(false)
            taskNameLabel.setText(currentTask.name)
        }
    }
    
    func fire() {
        timer.stop()
        startButtonImage.setHidden(false)
        timer.setHidden(true)
        guard let current = TasksManager.instance.currentTask else {return}
        print("FIRE: \(current.name)")
        current.stop()
        group.stopAnimating()
        display(TasksManager.instance.currentTask)
    }
    
    func display(task: Task?) {
        guard let task = task else {
            taskNameLabel.setText("NOTHING TO DO :)")
            timer.setHidden(true)
            startButtonImage.setHidden(true)
            return
        }
        group.setBackgroundImageNamed("Time0")
        taskNameLabel.setText(task.name)
    }

}
