//
//  Activity.swift
//  Pom
//
//  Created by Corinne Krych on 27/02/16.
//  Copyright © 2016 corinne. All rights reserved.
//

import Foundation

public let TaskInterval = NSTimeInterval(10)
public let WorkkoutInterval = NSTimeInterval(5)
public let LongWorkoutInterval = NSTimeInterval(5)

public protocol Activity {
    var name: String {get}
    var duration: NSTimeInterval {get}
    var activitiesManager: ActivitiesManager {get}
    var startDate: NSDate? {get set}
    var endDate: NSDate? {get set}
    var timer: NSTimer? {get set}
    var remainingTime: NSTimeInterval? {get}
    func start()
    func stopAndGoNext()
    func isStarted() -> Bool
    init(name: String, duration: NSTimeInterval, manager: ActivitiesManager)
}

public class TaskActivity: Activity {
    public let name: String
    public let duration: NSTimeInterval
    public let activitiesManager: ActivitiesManager
    public var startDate: NSDate?
    public var endDate: NSDate?
    public var timer: NSTimer?
    
    public var remainingTime: NSTimeInterval? {
        get {
            return timer?.fireDate.timeIntervalSinceNow
        }
    }
    
    public required init(name: String, duration: NSTimeInterval, manager: ActivitiesManager) {
        self.name = name
        self.duration = duration
        activitiesManager = manager
    }
    
    public convenience init(name: String, manager: ActivitiesManager) {
        self.init(name: name, duration: NSTimeInterval(TaskInterval), manager: manager)
    }
    
    public func start() {
        startDate = NSDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: "stop", userInfo: nil, repeats: false)
    }
    
    public func stopAndGoNext() {
        endDate = NSDate()
        timer?.invalidate()
        activitiesManager.setNext()
    }
    
    public func isStarted() -> Bool {
        return timer?.valid ?? false
    }
}

public class WorkoutActivity: Activity {
    public let name: String
    public let duration: NSTimeInterval
    public let activitiesManager: ActivitiesManager
    public var startDate: NSDate?
    public var endDate: NSDate?
    public var timer: NSTimer?
    
    public var remainingTime: NSTimeInterval? {
        get {
            return timer?.fireDate.timeIntervalSinceNow
        }
    }
    
    public required init(name: String, duration: NSTimeInterval, manager: ActivitiesManager) {
        self.name = name
        self.duration = duration
        self.activitiesManager = manager
    }
    
    public convenience init(name: String, manager: ActivitiesManager) {
        self.init(name: name, duration: NSTimeInterval(WorkkoutInterval), manager: manager)
    }
    
    public func start() {
        startDate = NSDate()
        timer = NSTimer(timeInterval: duration, target: self, selector: "stop", userInfo: nil, repeats: false)
    }
    
    public func stopAndGoNext() {
        endDate = NSDate()
        timer?.invalidate()
        activitiesManager.setNext()
    }
    
    public func isStarted() -> Bool {
        return timer?.valid ?? false
    }
}