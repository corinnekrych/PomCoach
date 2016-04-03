//
//  ActivitiesViewController.swift
//  Pom
//
//  Created by Corinne Krych on 02/03/16.
//  Copyright © 2016 corinne. All rights reserved.
//

import UIKit

public func displayError(error: String, viewController: UIViewController) {
    let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
    let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
    alert.addAction(okAction)
    viewController.presentViewController(alert, animated: true, completion: nil)
}

class ActivitiesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var activitiesMgr = ActivitiesManager.instance
    
    var newTaskCell: NewTaskCell?
    var addingNewTask: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorStyle = .None
        loadSavedTasks()
        sendActivitiesToAppleWatch(self)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("timerFired:"), name: "TimerFired", object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("timerStarted:"), name: "TimerStarted", object: nil)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
}

// MARK: TaskStarted TaskFired event
extension ActivitiesViewController {
    @objc func timerFired(note: NSNotification) {
        saveTasks()
        
        if let userInfo = note.object,
            let taskFromNotification = userInfo["task"] as? TaskActivity  {
            if let sender = userInfo["sender"] as? String where sender == "watch" {
                print("::Activity fired from watch")
            } else {
                print("::Activity fired from iOS")
                sendActivitiesToAppleWatch(self)
            }
            print("iOS app::TimerFired::TaskNotification::\(taskFromNotification)")
            dispatch_async(dispatch_get_main_queue()) {
                self.tableView.reloadData()
            }
        }
    }
    @objc func timerStarted(note: NSNotification) { //started from watch
        saveTasks()
        dispatch_async(dispatch_get_main_queue()) {
            print("iOSS App: TimerStarted Notification")
            self.tableView.reloadData()
        }
    }
}

// MARK: Update context
func sendActivitiesToAppleWatch(viewController: UIViewController) {
    print("sendActivitiesToAppleWatch")
    if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
        // send to watch
        print("sendActivitiesToAppleWatch::delegateSession")
        if delegate.session.paired && delegate.session.watchAppInstalled {
            print("sendActivitiesToAppleWatch::watchinstalled")
            if let remainingActivities = ActivitiesManager.instance.remainingActivities {
                
                let dict = remainingActivities.map({ (task: TaskActivity) -> [String: AnyObject] in
                    return task.toDictionary()
                })
                do {
                    print("sendActivitiesToAppleWatch::updateApplicationContext")
                    try delegate.session.updateApplicationContext(["activities": dict])
                } catch let error {
                    let alertController = UIAlertController(title: "Oops!", message: "Error: \(error). Please send again!", preferredStyle: .Alert)
                    viewController.presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
}

func sendActivityToAppleWatch(task: TaskActivity, viewController: UIViewController) {
    if let delegate = UIApplication.sharedApplication().delegate as? AppDelegate {
        print("send to watch")
        if delegate.session.paired && delegate.session.watchAppInstalled {
            do {
                print("sendActivityToAppleWatch \(task)")
                try delegate.session.updateApplicationContext(["task": task.toDictionary()])
            } catch let error {
                let alertController = UIAlertController(title: "Oops!", message: "Error: \(error). Please send again!", preferredStyle: .Alert)
                viewController.presentViewController(alertController, animated: true, completion: nil)
            }
        }
    }
}



// MARK: segue
extension ActivitiesViewController {
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let id = segue.identifier where id == "viewTask" {
            if let dest = segue.destinationViewController as? DetailledActivityViewController {
                if let taskCell = sender as? TaskCell, let task = taskCell.activity {
                    dest.task = task
                }
            }
        }
    }
}
// MARK: Delete / Move task
extension ActivitiesViewController {
    func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        return .Delete
    }
    
    func tableView(tableView: UITableView, shouldIndentWhileEditingRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    func tableView(tableView: UITableView, moveRowAtIndexPath sourceIndexPath: NSIndexPath, toIndexPath destinationIndexPath: NSIndexPath) {
        if sourceIndexPath.section == 0 {
            guard var remainingActivities = activitiesMgr.remainingActivities else {return}
            let moved = remainingActivities[sourceIndexPath.row]
            remainingActivities.removeAtIndex(sourceIndexPath.row)
            remainingActivities.insert(moved, atIndex: destinationIndexPath.row)
            activitiesMgr.remainingActivities = remainingActivities
        }
    }
    
    func tableView(tableView: UITableView, targetIndexPathForMoveFromRowAtIndexPath sourceIndexPath: NSIndexPath, toProposedIndexPath proposedDestinationIndexPath: NSIndexPath) -> NSIndexPath {
        if sourceIndexPath.section != proposedDestinationIndexPath.section {
            var row = 0
            if sourceIndexPath.section < proposedDestinationIndexPath.section {
                row = self.tableView(tableView, numberOfRowsInSection: sourceIndexPath.section) - 1
            }
            return NSIndexPath(forRow: row, inSection: sourceIndexPath.section)
        }
        return proposedDestinationIndexPath
    }
}

// MARK: Add New Task
extension ActivitiesViewController {
    @IBAction func editMode(sender: UIBarButtonItem) {
        self.tableView.editing = !self.tableView.editing
        saveTasks()
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete && indexPath.section == 0 {
            // Delete the row from the data source
            // meals.removeAtIndex(indexPath.row)
            guard var remainingActivities = activitiesMgr.remainingActivities else {return}
            if remainingActivities.count > 0 {
                remainingActivities.removeAtIndex(indexPath.row)
                activitiesMgr.remainingActivities = remainingActivities
                if remainingActivities.count == 0 { // always keep on row in section 0
                    tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
                } else {
                    tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
                }
            }
            tableView.reloadData()
        }
    }
    
    @IBAction func beginAddingTask() {
        addingNewTask = true
        tableView.allowsSelection = false
        if (activitiesMgr.remainingActivities != nil && activitiesMgr.remainingActivities?.count > 0) {
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
        } else {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Bottom)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "finishAddingTask")
    }
    
    func finishAddingTask() {
        guard let name = newTaskCell?.taskNameField.text where name.characters.count > 0 else {
            displayError("Name me!", viewController: self)
            return
        }
        
        guard let color = newTaskCell?.selectedColor else {
            displayError("Dont' know that Color????", viewController: self)
            return
        }
        
        let task = TaskActivity(name: name, duration: TaskInterval, type: color, manager: ActivitiesManager.instance)
        activitiesMgr.activities?.insert(task, atIndex: 0)
        addingNewTask = false
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
        newTaskCell?.reset()
        saveTasks()
        tableView.reloadData()
        tableView.endEditing(true)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "beginAddingTask")
        sendActivitiesToAppleWatch(self)
        tableView.allowsSelection = true
    }
}

// MARK: UITableViewDelegate
extension ActivitiesViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if  (indexPath.section == 1 || activitiesMgr.activities == nil) {
            return
        }
        guard indexPath.section != 1 else { return }
        guard activitiesMgr.activities!.count != 0 else {
            return
        }
        guard !(addingNewTask && indexPath.section == 0 && indexPath.row == 0) else { return }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let cell = cell as? NewTaskCell {
            cell.taskNameField.becomeFirstResponder()
        }
    }
}

// MARK: UITableViewDataSource
extension ActivitiesViewController: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            if addingNewTask {
                return 1 + (activitiesMgr.remainingActivities?.count ?? 0)
            } else {
                return max(1, activitiesMgr.remainingActivities?.count ?? 0)
            }
        }
        else if section == 1 {
            if let completed = activitiesMgr.completedActivities {
            return completed.count
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if (indexPath.section == 0 && indexPath.row == 0) {
            if addingNewTask {
                let cell = tableView.dequeueReusableCellWithIdentifier("NewTaskCell", forIndexPath: indexPath) as! NewTaskCell
                newTaskCell = cell
                return cell
            }
            else if activitiesMgr.remainingActivities == nil || activitiesMgr.remainingActivities?.count == 0 {
                // Placeholder when there are no ongoing tasks
                return tableView.dequeueReusableCellWithIdentifier("NoOngoingCell", forIndexPath: indexPath)
            } 
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TaskCell.ReuseId, forIndexPath: indexPath) as! TaskCell
        let task = indexPath.section == 0 ? activitiesMgr.remainingActivities![indexPath.row] : activitiesMgr.completedActivities![indexPath.row]
        if (indexPath.section == 0 && indexPath.row == 0 && task.isStarted()) {
            cell.updateWithTask(task, postfix: "Started")
        } else {
            cell.updateWithTask(task)
        }
        
        return cell
    }
    
    // Completed Header
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if let completed = activitiesMgr.completedActivities {
            if section == 1 && completed.count > 0 {
                return 30
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 && activitiesMgr.activities!.count > 0 else { return nil }
        let label = UILabel()
        label.text = "COMPLETED"
        label.textAlignment = .Center
        label.textColor = UIColor.whiteColor()
        
        return label
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (addingNewTask && indexPath.row == 0 && indexPath.section == 0) {
            return 90
        }
        return 60
    }
}

