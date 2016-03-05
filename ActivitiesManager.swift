//
//  ActivitiesManager.swift
//  Pom
//
//  Created by Corinne Krych on 28/02/16.
//  Copyright © 2016 corinne. All rights reserved.
//

import Foundation

public class ActivitiesManager {
    public var activities: [Activity]?
    public static let instance = ActivitiesManager()
    
    public init() {
      // TODO: remove hardcoded
        activities = [
//            TaskActivity(name: "task1", manager: self),
//            TaskActivity(name: "break1", duration: WorkkoutInterval, type:.Break, manager: self),
//            TaskActivity(name: "task2", manager: self),
//            TaskActivity(name: "shall we take a short break2 reallllly is that a good idea? niot so sure", duration: WorkkoutInterval, type:.Break, manager: self),
//            TaskActivity(name: "task3", manager: self),
            TaskActivity(name: "break3", duration: WorkkoutInterval, type:.Break, manager: self),
//            TaskActivity(name: "task4", manager: self),
            TaskActivity(name: "longerbreak1", duration: NSTimeInterval(4), type: .LongBreak, manager: self)]
    }
    
    public func isCurrentActivityStarted() -> Bool {
        return currentActivity?.timer?.valid ?? false
    }
    
    public var remainingActivities:[Activity]? {
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
    
    public var currentActivity:Activity? {
        get {
            guard let activities = remainingActivities else {return nil}
            if activities.count == 0 {return nil}
            return activities[0]
        }
    }
    
    public var completedActivities:[Activity]? {
        get {
            return activities?.filter {$0.endDate != nil}
        }
    }
    
}