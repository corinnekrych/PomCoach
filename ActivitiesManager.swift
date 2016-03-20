//
//  ActivitiesManager.swift
//  Pom
//
//  Created by Corinne Krych on 28/02/16.
//  Copyright © 2016 corinne. All rights reserved.
//

import Foundation

public func saveTasks() {
    print("Saving...")
    if let activities = ActivitiesManager.instance.activities {
        let object = NSKeyedArchiver.archivedDataWithRootObject(activities)
        NSUserDefaults.standardUserDefaults().setObject(object, forKey: "objects")
        NSUserDefaults.standardUserDefaults().synchronize()
        print("Saved...")
    }
}

public func loadSavedTasks() {
    if let savedObjects = NSUserDefaults.standardUserDefaults().objectForKey("objects") as? NSData {
        let act = NSKeyedUnarchiver.unarchiveObjectWithData(savedObjects) as! [TaskActivity]
        act.map({ (task: TaskActivity) -> TaskActivity in
            print("act::\(task.name)::\(task.startDate)::\(task.endDate)::\(task.duration)::\(task.type)")
            return task
        })
        ActivitiesManager.instance.activities = act
    }
}

final public class ActivitiesManager {
    public var activities: [TaskActivity]? = []
    public static let instance = ActivitiesManager()
    
    public init() {
    }
    
    public init(activities: [TaskActivity]) {
        self.activities = activities
    }
    
    public func isCurrentActivityStarted() -> Bool {
        return currentActivity?.timer?.valid ?? false
    }
    
    public var remainingActivities:[TaskActivity]? {
        get {
            return activities?.filter {$0.endDate == nil}
        }
        set {
            if let newValue = newValue {
                if let completedActivities = completedActivities {
                    activities = newValue + completedActivities
                } else {
                    activities = newValue
                }
            } else {
                activities = completedActivities
            }
            
        }
    }
    
    public var currentActivity:TaskActivity? {
        get {
            guard let activities = remainingActivities else {return nil}
            if activities.count == 0 {return nil}
            return activities[0]
        }
    }
    
    public var completedActivities:[TaskActivity]? {
        get {
            return activities?.filter {$0.endDate != nil}
        }
    }
}
