//
//  Activity.swift
//  Pom
//
//  Created by Corinne Krych on 27/02/16.
//  Copyright © 2016 corinne. All rights reserved.
//

import Foundation

public let TaskInterval = NSTimeInterval(10)
public let WorkoutInterval = NSTimeInterval(5)
public let LongWorkoutInterval = NSTimeInterval(5)
import UIKit

public enum ActivityType: Int, CustomStringConvertible {
    case Task = 0, Break = 1, LongBreak = 2
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
    
    public init?(rawValue: Int) {
        switch rawValue {
        case 0: self = .Task
        case 1: self = .Break
        case 2: self = .LongBreak
        default: return nil
        }
    }
}

public protocol Activity: CustomStringConvertible {
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
    init(name: String, duration: NSTimeInterval, startDate: NSDate?, endDate: NSDate?, type: ActivityType, manager: ActivitiesManager)
}

final public class TaskActivity: NSObject, Activity {
    public let name: String
    public let duration: NSTimeInterval
    public let activitiesManager: ActivitiesManager
    public var startDate: NSDate?
    public var endDate: NSDate?
    public var timer: NSTimer?
    public var type: ActivityType
    
    
    public override var description: String {
        return "\(self.name)"
    }
    
    public var remainingTime: NSTimeInterval? {
        get {
            return timer?.fireDate.timeIntervalSinceNow
        }
    }
    
    public required init(name: String, duration: NSTimeInterval, startDate: NSDate? = nil, endDate: NSDate? = nil, type: ActivityType = .Task, manager: ActivitiesManager) {
        self.name = name
        self.duration = duration
        self.type = type
        activitiesManager = manager
    }
    
    public convenience init(name: String, manager: ActivitiesManager) {
        self.init(name: name, duration: NSTimeInterval(TaskInterval), startDate:nil, endDate: nil,  manager: manager)
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

// MARK: NSCoding
extension TaskActivity: NSCoding {

    public convenience init?(coder aDecoder: NSCoder) {
        guard let name = aDecoder.decodeObjectForKey("name") as? String,
            let duration = aDecoder.decodeObjectForKey("duration") as? NSTimeInterval,
            let intType = aDecoder.decodeObjectForKey("type") as? Int, let type = ActivityType(rawValue:intType)
            else {return nil}
        var date1: NSDate? = nil
        if let startDate = aDecoder.decodeObjectForKey("startDate") as? NSDate {
            date1 = startDate
        }
        var date2: NSDate? = nil
        if let endDate = aDecoder.decodeObjectForKey("endDate") as? NSDate {
            date2 = endDate
        }
        self.init(name: name, duration: duration, startDate: date1, endDate: date2, type: type, manager: ActivitiesManager.instance)
    }
    
    public func encodeWithCoder(encoder: NSCoder) {
        encoder.encodeObject(name, forKey: "name")
        encoder.encodeObject(duration, forKey: "duration")
        encoder.encodeObject(type.rawValue, forKey: "type")
        if let startDate = startDate {
            encoder.encodeObject(startDate, forKey: "startDate")
        }
        if let endDate = endDate {
            encoder.encodeObject(endDate, forKey: "endDate")
        }
    }}