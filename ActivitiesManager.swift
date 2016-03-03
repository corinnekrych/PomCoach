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
            TaskActivity(name: "task1", manager: self),
            WorkoutActivity(name: "break1", manager: self),
            TaskActivity(name: "task2", manager: self),
            WorkoutActivity(name: "break2", manager: self),
            TaskActivity(name: "task3", manager: self),
            WorkoutActivity(name: "break3", manager: self),
            TaskActivity(name: "task4", manager: self),
            WorkoutActivity(name: "longerbreak1", duration: LongWorkoutInterval, manager: self)]
    }
    
    public func isCurrentActivityStarted() -> Bool {
        return currentActivity?.timer?.valid ?? false
    }
    
    public var remainingActivities:[Activity]? {
        get {
            return activities?.filter {$0.endDate == nil}
        }
    }
    
    public var currentActivity:Activity? {
        get {
            guard let activities = remainingActivities else {return nil}
            return activities[0] ?? nil
        }
    }
    
    public var completedActivities:[Activity]? {
        get {
            return activities?.filter {$0.endDate != nil}
        }
    }
    
}