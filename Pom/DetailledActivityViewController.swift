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
    
    @IBAction func startTimer(sender: AnyObject) {
        if task.isStarted() {
            displayError("Already started")
        } else if task.endDate == nil {
            if task.name == ActivitiesManager.instance.currentActivity?.name {
                statusLabel.text = "\(task.name) is Started"
                startButton.setTitle("Stop ", forState: .Normal)
                startButton.setTitle("Stop ", forState: .Selected)
                task.start()
                saveTasks()
            } else {
                displayError("Do your tasks in order :P")
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("timerFired"), name: "TimerFired", object: nil)
        let state = task.endDate != nil ? "done" :(task.startDate == nil ? "toStart" : "isStarted")
        if state == "isStarted" {
            statusLabel.text = "\(task.name) is started"
            startButton.setTitle("Stop ", forState: .Normal)
            startButton.setTitle("Stop ", forState: .Selected)
        } else if state == "toStart" {
            statusLabel.text = "\(task.name)"
            startButton.setTitle("Start ", forState: .Normal)
            startButton.setTitle("Start ", forState: .Selected)
        } else {
            statusLabel.text = "\(task.name) is done"
            startButton.setTitle("Done", forState: .Normal)
            startButton.setTitle("Done", forState: .Selected)
        }
    }
    
    public func timerFired() {
        statusLabel.text = "\(task.name) is done"
        startButton.setTitle("Done", forState: .Normal)
        startButton.setTitle("Done", forState: .Selected)
        saveTasks()
    }
    
    func saveTasks() {
        print("Saving...")
        if let activities = ActivitiesManager.instance.activities {
            let object = NSKeyedArchiver.archivedDataWithRootObject(activities)
            NSUserDefaults.standardUserDefaults().setObject(object, forKey: "objects")
            NSUserDefaults.standardUserDefaults().synchronize()
            print("Saved...")
        }
    }
}
// MARK: Utility methods
extension DetailledActivityViewController {
    func displayError(error: String) {
        let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
    }
}