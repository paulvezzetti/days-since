//
//  ActivityStatistics.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/20/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

class ActivityStatistics {
    
    // TODO: These should be private
    let activity:ActivityMO
    let sortedEvents: [EventMO]
    let intervals: [TimeInterval]
    let dateIntervals: [DateInterval]
    let maxInterval: TimeInterval
    let minInterval: TimeInterval
    let avgInterval: TimeInterval
    let dateFormatter: DateFormatter
    
    
    // TODO: Should all dates be normalized???
    init(activity:ActivityMO) {
        self.activity = activity
        
        dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        
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
        
        return Int(floor(numSecondsSinceLast / TimeConstants.SECONDS_PER_DAY))
    }
    
    var daysUntil:Int {
        guard let lastEvent = sortedEvents.last else {
            return -1
        }
        let frequency = activity.frequency
        let addedTime: TimeInterval = TimeInterval(frequency) * TimeConstants.SECONDS_PER_DAY //Double(frequency * 24 * 60 * 60)
        let nextExpectedEvent = lastEvent.timestamp?.addingTimeInterval(addedTime)
        
        let numSecsToNextEvent =  nextExpectedEvent?.timeIntervalSince(Date())
        return Int(floor(numSecsToNextEvent! / TimeConstants.SECONDS_PER_DAY))
    }
    
    var nextDate:Date {
        guard let lastEvent = sortedEvents.last else {
            return Date() // TODO: How to handle??
        }
        let frequency = activity.frequency
        let addedTime: TimeInterval = TimeInterval(frequency) * TimeConstants.SECONDS_PER_DAY //Double(frequency * 24 * 60 * 60)
        return lastEvent.timestamp?.addingTimeInterval(addedTime) ?? Date()
    }
    
    var nextDay:String {
        return dateFormatter.string(from: nextDate)
    }
    
    var lastDate:Date? {
        guard let lastEvent = sortedEvents.last else {
            return nil // TODO: How to handle??
        }
        return lastEvent.timestamp
    }
    
    var lastDay:String {
        guard let last = lastDate else {
            return "Unknown"
        }
        return dateFormatter.string(from: last)
    }
    
    
    var maxDays: Int {
        return Int(floor(maxInterval / TimeConstants.SECONDS_PER_DAY))
    }
    
    var minDays: Int {
        return Int(floor(minInterval / TimeConstants.SECONDS_PER_DAY ))
    }
    
    var avgDays:Int {
        return Int(floor(avgInterval / TimeConstants.SECONDS_PER_DAY))
    }
    
    var firstEvent:Date? {
        if sortedEvents.count == 0 {
            return nil
        }
        return sortedEvents.first?.timestamp
    }
    
    var firstDay:String {
        guard let date = firstEvent else {
            return ""
        }
        return dateFormatter.string(from: date)
    }
    
}
