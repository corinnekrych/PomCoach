//
//  DetailledActivityViewController.swift
//  Pom
//
//  Created by Corinne Krych on 02/03/16.
//  Copyright © 2016 corinne. All rights reserved.
//

import UIKit

public class DetailledActivityViewController: UIViewController {
    public var task: TaskActivity!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var circleView: CircleView!
    
    @IBAction func startTimer(sender: AnyObject) {
        if task.isStarted() {
            displayError("Already started", viewController: self)
        } else if task.endDate == nil {
            if task.name == ActivitiesManager.instance.currentActivity?.name {
                task.start()
                // TODO: to avoid duplication send event but need a way to know where the action was started not to send notigication back
                //NSNotificationCenter.defaultCenter().postNotificationName("TimerStarted", object: ["task":task])
                saveTasks()
                sendActivityToAppleWatch(task, viewController: self)
                print("Task started from iOS app, sendActivityToAppleWatch() called")
                dispatch_async(dispatch_get_main_queue()) {
                    print("Task started from iOS app, sendActivityToAppleWatch() called.. MAIN")
                    self.circleView.animateCircle(0, color:self.task.type.color, duration: self.task.duration)
                    self.statusLabel.text = "\(self.task.name)"
                    self.startButton.setTitle("Stop ", forState: .Normal)
                    self.startButton.setTitle("Stop ", forState: .Selected)
                }
            } else {
                displayError("Do your tasks in order :P", viewController: self)
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("timerFired:"), name: "TimerFired", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("timerStarted:"), name: "TimerStarted", object: nil)
        let state = task.endDate != nil ? "done" :(task.startDate == nil ? "toStart" : "isStarted")
        if state == "isStarted" {
            statusLabel.text = "\(task.name)"
            startButton.setTitle("Stop ", forState: .Normal)
            startButton.setTitle("Stop ", forState: .Selected)
            let now = NSDate()
            let spent = now.timeIntervalSinceReferenceDate - (task.startDate?.timeIntervalSinceReferenceDate)!
            circleView.animateCircle(spent, color:task.type.color, duration: task.duration)
        } else if state == "toStart" {
            statusLabel.text = "\(task.name)"
            startButton.setTitle("Start ", forState: .Normal)
            startButton.setTitle("Start ", forState: .Selected)
        } else {
            statusLabel.text = "\(task.name)"
            startButton.setTitle("Done", forState: .Normal)
            startButton.setTitle("Done", forState: .Selected)
            circleView.animateCircle(task.duration, color:task.type.color, duration: task.duration)
        }
    }
    
    @objc public func timerFired(note: NSNotification) {
        if let userInfo = note.object, taskFromNotification = userInfo["task"] as? TaskActivity where taskFromNotification.name == self.task.name {
            saveTasks()
            sendActivitiesToAppleWatch(self)
            print("iOS app::TimerFired::TaskNotification::\(taskFromNotification)")
            dispatch_async(dispatch_get_main_queue()) {
                self.startButton.setTitle("Done", forState: .Normal)
                self.startButton.setTitle("Done", forState: .Selected)
            }
        }
        print("iOS app::TimerFired::note::\(note)")
    }
    
    @objc public func timerStarted(note: NSNotification) {
        if let userInfo = note.object, let taskFromNotification = userInfo["task"] as? TaskActivity where taskFromNotification.name == self.task.name {
            saveTasks()
            // TODO: to avoid duplication send event but need a way to know where the action was started not to send notigication back
            //sendActivityToAppleWatch(task, viewController: self)
            print("iOS app::TimerStarted::TaskNotification::\(taskFromNotification)")
            dispatch_async(dispatch_get_main_queue()) {
                self.startButton.setTitle("Stop", forState: .Normal)
                self.startButton.setTitle("Stop", forState: .Selected)
                let now = NSDate()
                let spent = now.timeIntervalSinceReferenceDate - (taskFromNotification.startDate?.timeIntervalSinceReferenceDate)!
                self.circleView.animateCircle(spent, color:taskFromNotification.type.color, duration: taskFromNotification.duration)
            }
        }
        print("iOS app::TimerStarted::note::\(note)")
    }
}


