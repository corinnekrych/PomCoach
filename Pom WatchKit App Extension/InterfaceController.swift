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
            currentTask.start()
            startButtonImage.setHidden(true)
            timer.setHidden(false)
            taskNameLabel.setText(currentTask.name)
        }
    }
    
    func display(task: Task?) {
        guard let task = task else {
            taskNameLabel.setText("NOTHING TO DO :)")
            timer.setHidden(true)
            startButtonImage.setHidden(true)
            return
        }
        taskNameLabel.setText(task.name)
    }

}
