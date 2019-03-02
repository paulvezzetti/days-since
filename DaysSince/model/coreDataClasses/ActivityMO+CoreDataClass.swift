//
//  ActivityMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/22/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ActivityMO)
public class ActivityMO: NSManagedObject {

//    enum SectionIndex: Int {
//        case onTime = 0, soon, overdue
//    }
//
//    var status:String {
//        return isOverdue ? "Overdue" : "On time"
//    }
    
    enum ActivityStatus: Int {
        case OverDue = 0, Soon, OnTime
    }
    
    var status:ActivityStatus {
        // TODO: Add soon ?
        return isOverdue ? ActivityStatus.OverDue : ActivityStatus.OnTime
    }
    
    
    var isOverdue: Bool {
        let intervalFreq = frequencyInSeconds
        if intervalFreq == 0 {
            return false // No frequency set, so it's never overdue
        }
        
        let history = sortedHistory
        
        guard let lastEvent = history.last else {
            return false
        }
        let due = lastEvent.timestamp?.addingTimeInterval(intervalFreq)
        return due! < Date();
    }
    
    var sortedHistory: [EventMO] {
        return history?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)]) as! [EventMO]
    }
    
    var firstDate: Date {
        let sortDates = sortedHistory
        return sortDates.isEmpty ? Date() : sortDates[0].timestamp!
    }
    
    private var frequencyInSeconds: Double {
        return Double(frequency) * TimeConstants.SECONDS_PER_DAY
    }

}
