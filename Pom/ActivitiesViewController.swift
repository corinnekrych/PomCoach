//
//  ActivitiesViewController.swift
//  Pom
//
//  Created by Corinne Krych on 02/03/16.
//  Copyright © 2016 corinne. All rights reserved.
//


import UIKit

class ActivitiesViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var activitiesMgr = ActivitiesManager.instance
    
    var newTaskCell: NewTaskCell?
    var addingNewTask: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        tableView.backgroundColor = UIColor.blackColor()
        tableView.separatorStyle = .None
        //loadSavedTasks()
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
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
            remainingActivities.removeAtIndex(indexPath.row)
            activitiesMgr.remainingActivities = remainingActivities
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
    }
    
    @IBAction func beginAddingTask() {
        addingNewTask = true
        
        if let _ = activitiesMgr.remainingActivities {
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Top)
        } else {
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Bottom)
        }
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Done, target: self, action: "finishAddingTask")
 
    }
    
    func finishAddingTask() {
        guard let name = newTaskCell?.taskNameField.text where name.characters.count > 0 else {
            displayError("Please add a Name")
            return
        }
        
        guard let color = newTaskCell?.selectedColor else {
            displayError("Invalid Color")
            return
        }
        
        let task = TaskActivity(name: name, duration: TaskInterval, type: color, manager: ActivitiesManager.instance)
        activitiesMgr.activities?.insert(task, atIndex: 0)
        addingNewTask = false
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: .Fade)
        newTaskCell?.reset()
        saveTasks()
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
        guard activitiesMgr.activities!.count != 0 else { return }
        guard !(addingNewTask && indexPath.section == 0 && indexPath.row == 0) else { return }
        
        let task = activitiesMgr.remainingActivities![indexPath.row]
        task.start()

        //saveTasks()
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
            } else if activitiesMgr.activities == nil {
                // Placeholder when there are no ongoing tasks
                return tableView.dequeueReusableCellWithIdentifier("NoOngoingCell", forIndexPath: indexPath)
            }
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(TaskCell.ReuseId, forIndexPath: indexPath) as! TaskCell
        
        let task = indexPath.section == 0 ? activitiesMgr.remainingActivities![indexPath.row] : activitiesMgr.completedActivities![indexPath.row]
        cell.updateWithTask(task)
        
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

