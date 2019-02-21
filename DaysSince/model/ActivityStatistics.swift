//
//  ActivityStatistics.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/20/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

class ActivityStatistics {
    
    let activity:ActivityMO
    let sortedEvents: [EventMO]
    let intervals: [TimeInterval]
    let dateIntervals: [DateInterval]
    let maxInterval: TimeInterval
    let minInterval: TimeInterval
    let avgInterval: TimeInterval
    
    
    // TODO: Should all dates be normalized???
    init(activity:ActivityMO) {
        self.activity = activity
        
        sortedEvents = activity.history?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)]) as! [EventMO]
        var timeIntervals:[TimeInterval] = []
        var dates:[DateInterval] = []
        var intervalSum: TimeInterval = 0
        var min:TimeInterval = Double.infinity
        var max:TimeInterval = 0
        
        for (index, history) in sortedEvents.enumerated() {
            if history == sortedEvents.last {
                break
            }
            let nextEvent = sortedEvents[index + 1]
            let dateInterval = nextEvent.timestamp!.timeIntervalSince(history.timestamp!)
            timeIntervals.append(dateInterval)
            
            if dateInterval > max {
                max = dateInterval
            }
            if dateInterval < min {
                min = dateInterval
            }
            intervalSum += dateInterval
            
            dates.append(DateInterval(start: history.timestamp!, end: nextEvent.timestamp!))
        }
        self.intervals = timeIntervals
        self.dateIntervals = dates
        
        self.avgInterval = self.intervals.count > 0 ? intervalSum / Double(self.intervals.count) : 0
        self.maxInterval = max
        self.minInterval = min < Double.infinity ? min : 0
    }
    
    var daySince:Int {
        guard let lastEvent = sortedEvents.last else {
            return -1
        }
        let numSecondsSinceLast = Date().timeIntervalSince(lastEvent.timestamp!)
        
        return Int(floor(numSecondsSinceLast / 60 / 60 / 24))
    }
    
    var daysUntil:Int {
        guard let lastEvent = sortedEvents.last else {
            return -1
        }
        let frequency = activity.frequency
        let addedTime: TimeInterval = TimeInterval(frequency) * 24 * 60 * 60 //Double(frequency * 24 * 60 * 60)
        let nextExpectedEvent = lastEvent.timestamp?.addingTimeInterval(addedTime)
        
        let numSecsToNextEvent =  nextExpectedEvent?.timeIntervalSince(Date())
        return Int(floor(numSecsToNextEvent! / 60 / 60 / 24))
    }
    
    var nextDay:Date {
        guard let lastEvent = sortedEvents.last else {
            return Date() // TODO: How to handle??
        }
        let frequency = activity.frequency
        let addedTime: TimeInterval = TimeInterval(frequency) * 24 * 60 * 60 //Double(frequency * 24 * 60 * 60)
        return lastEvent.timestamp?.addingTimeInterval(addedTime) ?? Date()
    }
    
    
    var maxDays: Int {
        return Int(floor(maxInterval / 24 / 60 / 60))
    }
    
    var minDays: Int {
        return Int(floor(minInterval / 24 / 60 / 60 ))
    }
    
    var avgDays:Int {
        return Int(floor(avgInterval / 24 / 60 / 60))
    }
    
    var firstEvent:Date? {
        if sortedEvents.count == 0 {
            return nil
        }
        return sortedEvents.first?.timestamp
    }
    
}
