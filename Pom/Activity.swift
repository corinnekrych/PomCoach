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
import UIKit

public enum ActivityType: Int, CustomStringConvertible {
    case Task, Break, LongBreak
    public static let allColors = [Task, Break, LongBreak]
    
    public var name: String {
        switch self {
        case .Task:     return "Task"
        case .Break:   return "Break"
        case .LongBreak:    return "LongBreak"
        }
    }
    
    public var color: UIColor {
        switch self {
        case .Task:    return UIColor(red: 4/255.0, green: 222/255.0, blue: 113/255.0, alpha: 1)
        case .Break:   return UIColor(red: 255/255.0, green: 149/255.0, blue: 0/255.0, alpha: 1)
        case .LongBreak:   return UIColor(red: 250/255.0, green: 200/255.0, blue: 20/255.0, alpha: 1)
        }
    }
    
    public var description: String {
        return name
    }
}

public protocol Activity {
    var name: String {get}
    var duration: NSTimeInterval {get}
    var activitiesManager: ActivitiesManager {get}
    var startDate: NSDate? {get set}
    var endDate: NSDate? {get set}
    var timer: NSTimer? {get set}
    var remainingTime: NSTimeInterval? {get}
    var type: ActivityType {get set}
    func start()
    func stop()
    func isStarted() -> Bool
    init(name: String, duration: NSTimeInterval, type: ActivityType, manager: ActivitiesManager)
}

public class TaskActivity: NSObject, Activity {
    public let name: String
    public let duration: NSTimeInterval
    public let activitiesManager: ActivitiesManager
    public var startDate: NSDate?
    public var endDate: NSDate?
    public var timer: NSTimer?
    public var type: ActivityType
    
    public var remainingTime: NSTimeInterval? {
        get {
            return timer?.fireDate.timeIntervalSinceNow
        }
    }
    
    public required init(name: String, duration: NSTimeInterval, type: ActivityType = .Task, manager: ActivitiesManager) {
        self.name = name
        self.duration = duration
        self.type = type
        activitiesManager = manager
    }
    
    public convenience init(name: String, manager: ActivitiesManager) {
        self.init(name: name, duration: NSTimeInterval(TaskInterval), manager: manager)
    }
    
    public func start() {
        startDate = NSDate()
        timer = NSTimer.scheduledTimerWithTimeInterval(duration, target: self, selector: Selector("stop"), userInfo: nil, repeats: false)
    }
    
    public func stop() {
        print("fire")
        endDate = NSDate()
        timer?.invalidate()
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
    public var type: ActivityType
    
    public var remainingTime: NSTimeInterval? {
        get {
            return timer?.fireDate.timeIntervalSinceNow
        }
    }
    
    public required init(name: String, duration: NSTimeInterval, type: ActivityType = .Break, manager: ActivitiesManager) {
        self.name = name
        self.duration = duration
        self.type = type
        self.activitiesManager = manager
    }
    
    public convenience init(name: String, manager: ActivitiesManager) {
        self.init(name: name, duration: NSTimeInterval(WorkkoutInterval), manager: manager)
    }
    
    public func start() {
        startDate = NSDate()
        timer = NSTimer(timeInterval: duration, target: self, selector: "stop", userInfo: nil, repeats: false)
    }
    
    public func stop() {
        endDate = NSDate()
        timer?.invalidate()
    }
    
    public func isStarted() -> Bool {
        return timer?.valid ?? false
    }
}