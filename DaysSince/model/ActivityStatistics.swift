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
    
    
    // TODO: Should all dates be normalized???
    init(activity:ActivityMO) {
        self.activity = activity
        
        sortedEvents = activity.history?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)]) as! [EventMO]
        var timeIntervals:[TimeInterval] = []
        var dates:[DateInterval] = []
        for (index, history) in sortedEvents.enumerated() {
            if history == sortedEvents.last {
                break
            }
            let nextEvent = sortedEvents[index + 1]
            let dateInterval = nextEvent.timestamp!.timeIntervalSince(history.timestamp!)
            timeIntervals.append(dateInterval)
            
            dates.append(DateInterval(start: history.timestamp!, end: nextEvent.timestamp!))
        }
        self.intervals = timeIntervals
        self.dateIntervals = dates
    }
    
    var daySince:Int {
        guard let lastEvent = sortedEvents.last else {
            return -1
        }
        let numSecondsSinceLast = Date().timeIntervalSince(lastEvent.timestamp!)
        
        return Int(floor(numSecondsSinceLast / 60 / 60 / 24))
    }
    
    
    
    
    
    
    
}
