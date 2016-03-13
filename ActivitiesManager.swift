//
//  ActivitiesManager.swift
//  Pom
//
//  Created by Corinne Krych on 28/02/16.
//  Copyright © 2016 corinne. All rights reserved.
//

import Foundation

final public class ActivitiesManager: NSObject {
    public var activities: [TaskActivity]?
    public static let instance = ActivitiesManager()
    
    public override init() {
        super.init()
        // TODO: remove hardcoded
        activities = []
//        activities = [
//            TaskActivity(name: "read emails", manager: self),
//            TaskActivity(name: "10 curls", duration: WorkoutInterval, type:.Break, manager: self),
//            TaskActivity(name: "layout", manager: self),
//            TaskActivity(name: "coffee", duration: WorkoutInterval, type:.Break, manager: self),
//            TaskActivity(name: "animation", manager: self),
//            TaskActivity(name: "10 push ups", duration: WorkoutInterval, type:.Break, manager: self),
//            TaskActivity(name: "glance 1/2", manager: self),
//            
//            TaskActivity(name: "walk outside", duration: LongWorkoutInterval, type:.Break, manager: self), //2h30
//            
//            TaskActivity(name: "glace 2/2", manager: self),
//            TaskActivity(name: "10 push ups", duration: WorkoutInterval, type:.Break, manager: self),
//            TaskActivity(name: "complication", manager: self),
//            TaskActivity(name: "50 crunchies", duration: WorkoutInterval, type:.Break, manager: self),
//            TaskActivity(name: "WC: Interactive Messaging", manager: self),
//            TaskActivity(name: "10 squats/leg raises", duration: WorkoutInterval, type:.Break, manager: self),
//            TaskActivity(name: "WC: Application Context", manager: self),
//            
//            TaskActivity(name: "footing", duration: LongWorkoutInterval, type:.Break, manager: self)]
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
// MARK: NSCoding
extension ActivitiesManager: NSCoding {
    
    public convenience init?(coder aDecoder: NSCoder) {
        guard let activities = aDecoder.decodeObjectForKey("activities") as? [TaskActivity]
            else {return nil}
        
        self.init(activities: activities)
    }
    
    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(activities, forKey: "activities")
    }
}