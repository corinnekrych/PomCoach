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
        
        if (WCSession.isSupported()) {
            session = WCSession.defaultSession()
            session.delegate = self;
            session.activateSession()
        }
        //loadSavedTasks()
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
        var task = tasks[0]
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
        replyHandler(["taskId": task.name, "status": "updated ok"])
        dispatch_async(dispatch_get_main_queue()) {
            self.tableView.reloadData()
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
        
        let task = activitiesMgr.remainingActivities![indexPath.row]
        
        if(task.name != activitiesMgr.currentActivity!.name) {
            displayError("Do your tasks in order ;)")
        }
        if (task.startDate != nil) {
            displayError("\(task.name) is alreday started :P")
        }
        
        let alert = UIAlertController(title: task.name, message: "Do you want to start \(task.name)?", preferredStyle: .ActionSheet)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: { (action: UIAlertAction) -> Void in
            let cell = tableView.cellForRowAtIndexPath(indexPath) as! TaskCell
            let userInfo = ["index": indexPath.row, "cell": cell]
            let _ = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("update:"), userInfo: userInfo, repeats: true)
            task.start()
        })
        
        alert.addAction(okAction)
        alert.addAction(UIAlertAction(title: "Cancel", style: .Default, handler: nil))
        alert.view.tintColor = UIColor.blackColor()
        let subview = alert.view.subviews.first! as UIView
        let alertContentView = subview.subviews.first! as UIView
        alertContentView.backgroundColor = UIColor.blackColor()
        alert.view.tintColor = UIColor.whiteColor();
        self.presentViewController(alert, animated: true, completion: nil)
        // workaround for http://stackoverflow.com/questions/21075540/presentviewcontrolleranimatedyes-view-will-not-appear-until-user-taps-again
        CFRunLoopWakeUp(CFRunLoopGetCurrent());
        saveTasks()
    }
    
    func update(timer: NSTimer) {
        guard let userInfo = timer.userInfo else {return}
        let index = userInfo["index"] as! Int
        let cell = userInfo["cell"] as! TaskCell
        guard let tasks = activitiesMgr.remainingActivities else {return}
        if tasks.count > 0 {
            let timeRemaining = tasks[index].remainingTime
            let color = tasks[index].type.color
            let totalTime = tasks[index].duration
            if timeRemaining == nil {
                timer.invalidate();
                cell.progressView.update(color, current: Int(totalTime), total: Int(totalTime))
                tableView.reloadData()
                return
            }
            
            let timePassed = Int(totalTime - timeRemaining!) as Int
            cell.progressView.update(color, current: timePassed, total: Int(totalTime))
        } else { // last row
            tableView.reloadData()
        }
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
    private var savedTasksPath: String {
        let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let docPath = paths.first!
        return (docPath as NSString).stringByAppendingPathComponent("SavedTasks")
    }
    
    func loadSavedTasks() {
//        if let data = NSData(contentsOfFile: savedTasksPath) {
//            let savedTasks = NSKeyedUnarchiver.unarchiveObjectWithData(data) as! TaskList
//            tasks = savedTasks
//        } else {
//            tasks = TaskList()
//        }
    }
    
    func saveTasks() {
        print("REMAINING\(activitiesMgr.remainingActivities)")
        //NSKeyedArchiver.archiveRootObject(tasks, toFile: savedTasksPath)
    }
}

