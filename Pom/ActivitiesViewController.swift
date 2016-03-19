//
//  ActivitiesViewController.swift
//  Pom
//
//  Created by Corinne Krych on 02/03/16.
//  Copyright © 2016 corinne. All rights reserved.
//

import UIKit
import WatchConnectivity

class ActivitiesViewController: UIViewController, WCSessionDelegate {
    @IBOutlet weak var tableView: UITableView!
    
    var activitiesMgr = ActivitiesManager.instance
    
    var newTaskCell: NewTaskCell?
    var addingNewTask: Bool = false
    
    var session : WCSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorStyle = .None
        loadSavedTasks()
        sendContextToAppleWatch()
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("timerFired"), name: "TimerFired", object: nil)
    }

    func timerFired() {
        saveTasks()
        tableView.reloadData()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func session(session: WCSession, didReceiveMessage message: [String : AnyObject], replyHandler: ([String : AnyObject]) -> Void) {
        print("RECEIVED ON IOS: \(message)")
        let taskName = message["task"] as? String
        let tasksFiltered = activitiesMgr.activities?.filter {$0.name == taskName}
        guard let tasks = tasksFiltered else {return}
        let task = tasks[0]
        if task.isStarted() {
            replyHandler(["taskId": task.name, "status": "started"])
            return
        }
        if task.endDate != nil {
            replyHandler(["taskId": task.name, "status": "finished"])
            return
        }
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let startDateString = message["start"] as? String
        var startDate: NSDate? = nil
        if let startDateString = startDateString {
            startDate = dateFormatter.dateFromString(startDateString)
        }
        task.startDate = startDate
        
        let endDateString = message["end"] as? String
        var endDate:NSDate? = nil
        if let endDateString = endDateString {
            endDate = dateFormatter.dateFromString(endDateString)
        }
        task.endDate = endDate
        
        dispatch_async(dispatch_get_main_queue()) {
            
            self.tableView.reloadData()
            self.saveTasks()
        }
        replyHandler(["taskId": task.name, "status": "updated ok"])
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
            displayError("Name me!")
            return
        }
        
        guard let color = newTaskCell?.selectedColor else {
            displayError("Dont' know that Color????")
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
        sendContextToAppleWatch()
        tableView.allowsSelection = true
    }
    
    func sendContextToAppleWatch() {
        // send to watch
        if session.paired && session.watchAppInstalled {
            if let remainingActivities = activitiesMgr.remainingActivities {
                let dict = remainingActivities.map({ (task: TaskActivity) -> [String: AnyObject] in
                    return task.toDictionary()
                })
                do {
                    try session.updateApplicationContext(["activities": dict])
                } catch let error {
                    let alertController = UIAlertController(title: "Oops!", message: "Error: \(error). Please send again!", preferredStyle: .Alert)
                    presentViewController(alertController, animated: true, completion: nil)
                }
            }
        }
    }
    
    func displayError(error: String) {
        let alert = UIAlertController(title: error, message: nil, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        self.presentViewController(alert, animated: true, completion: nil)
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
                return 1 + activitiesMgr.remainingActivities!.count
            } else {
                return max(1, activitiesMgr.remainingActivities!.count)
            }
        }
        else if section == 1 {
            return activitiesMgr.completedActivities!.count
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
        if let activities = activitiesMgr.remainingActivities {
            if (activities.count > 0) {
                let task = indexPath.section == 0 ? activities[indexPath.row] : activitiesMgr.completedActivities![indexPath.row]
                cell.updateWithTask(task)
            }
        }
        return cell
    }
    
    // Completed Header
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 && activitiesMgr.completedActivities!.count > 0 {
            return 30
        }
        return 0
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard section == 1 && activitiesMgr.activities!.count > 0 else { return nil }
        let label = UILabel()
        label.text = "    COMPLETED"
        label.textColor = UIColor(red: 250/255.0, green: 17/255.0, blue: 79/255.0, alpha: 1)
        label.backgroundColor = UIColor(red: 250/255.0, green: 17/255.0, blue: 79/255.0, alpha: 1).colorWithAlphaComponent(0.17)
        
        return label
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (addingNewTask && indexPath.row == 0 && indexPath.section == 0) {
            return 90
        }
        return 60
    }
}

// MARK: Task Persistance
extension ActivitiesViewController {
    func loadSavedTasks() {
        if let savedObjects = NSUserDefaults.standardUserDefaults().objectForKey("objects") as? NSData {
            let act = NSKeyedUnarchiver.unarchiveObjectWithData(savedObjects) as! [TaskActivity]
            act.map({ (task: TaskActivity) -> TaskActivity in
                print("act::\(task.name)::\(task.startDate)::\(task.endDate)::\(task.duration)::\(task.type)")
                return task
            })
            activitiesMgr.activities = act
        }
    }
    
    func saveTasks() {
        print("Saving...")
        if let activities = activitiesMgr.activities {
            let object = NSKeyedArchiver.archivedDataWithRootObject(activities)
            NSUserDefaults.standardUserDefaults().setObject(object, forKey: "objects")
            NSUserDefaults.standardUserDefaults().synchronize()
            print("Saved...")
        }
    }
}

