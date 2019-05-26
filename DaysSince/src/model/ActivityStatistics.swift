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
    let onTimePercent: Double 
    
    
    // TODO: Should all dates be normalized???
    init(activity:ActivityMO) {
        self.activity = activity
        
        dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
//        dateFormatter.dateStyle = DateFormatter.Style.medium
//        dateFormatter.timeStyle = DateFormatter.Style.none
        
        sortedEvents = activity.history?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)]) as! [EventMO]
        var timeIntervals:[TimeInterval] = []
        var dates:[DateInterval] = []
        var intervalSum: TimeInterval = 0
        var min:TimeInterval = Double.infinity
        var max:TimeInterval = 0
        var nOnTime:Double = 0
        let calendar = Calendar.current
        
        for (index, history) in sortedEvents.enumerated() {
            if history == sortedEvents.last {
                break
            }
            
            let nextEvent = sortedEvents[index + 1]
            
            guard let nextActualDate = nextEvent.timestamp, let currentActualDate = history.timestamp else {
                continue
            }
            let dateInterval = nextActualDate.timeIntervalSince(currentActualDate)
            timeIntervals.append(dateInterval)
            dates.append(DateInterval(start: currentActualDate, end: nextActualDate))

            if dateInterval > max {
                max = dateInterval
            }
            if dateInterval < min {
                min = dateInterval
            }
            intervalSum += dateInterval
            
            guard let nextExpectedDate = activity.interval?.getNextDate(since: currentActualDate) else {
                continue
            }
            if calendar.compare(nextActualDate, to: nextExpectedDate, toGranularity: .day) != .orderedDescending {
                nOnTime += 1 // This one is on-time
            }
        }
        self.intervals = timeIntervals
        self.dateIntervals = dates
        
        self.avgInterval = self.intervals.count > 0 ? intervalSum / Double(self.intervals.count) : 0
        self.maxInterval = max
        self.minInterval = min < Double.infinity ? min : 0
        
        if activity.interval is UnlimitedIntervalMO {
            self.onTimePercent = 1
        } else {
            self.onTimePercent = sortedEvents.count <= 1 ? 1 : nOnTime / Double(sortedEvents.count - 1)
        }
    }
    
    var daySince:Int? {
        guard let lastEvent = sortedEvents.last else {
            return nil
        }
        let numSecondsSinceLast = Date().timeIntervalSince(lastEvent.timestamp!)
        
        return Int(floor(numSecondsSinceLast / TimeConstants.SECONDS_PER_DAY))
    }
    
    var daysUntil:Int? {
        guard let lastDate = activity.lastEvent?.timestamp, let nextDate = activity.interval?.getNextDate(since: lastDate) else {
            return nil
        }
        
        return Calendar.current.dateComponents([.day], from: Date(), to: nextDate).day
        
//
//        guard let lastEvent = sortedEvents.last else {
//            return -1
//        }
//        let frequency = activity.frequency
//        let addedTime: TimeInterval = TimeInterval(frequency) * TimeConstants.SECONDS_PER_DAY //Double(frequency * 24 * 60 * 60)
//        let nextExpectedEvent = lastEvent.timestamp?.addingTimeInterval(addedTime)
//
//        let numSecsToNextEvent =  nextExpectedEvent?.timeIntervalSince(Date())
//        return Int(floor(numSecsToNextEvent! / TimeConstants.SECONDS_PER_DAY))
    }
    
    var nextDate:Date? {

        guard let interval = activity.interval, let lastDate = activity.lastEvent?.timestamp else {
            return nil
        }
        return interval.getNextDate(since: lastDate)

//        guard let lastEvent = sortedEvents.last else {
//            return Date() // TODO: How to handle??
//        }
//        let frequency = activity.frequency
//        let addedTime: TimeInterval = TimeInterval(frequency) * TimeConstants.SECONDS_PER_DAY //Double(frequency * 24 * 60 * 60)
//        return lastEvent.timestamp?.addingTimeInterval(addedTime) ?? Date()
    }
    
    var nextDay:String {
        guard let next = self.nextDate else {
            return "--"
        }
        return dateFormatter.string(from: next)
        
        
       // return dateFormatter.string(from: nextDate)
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
    
    var avgDays:Double {
        return avgInterval / TimeConstants.SECONDS_PER_DAY
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
