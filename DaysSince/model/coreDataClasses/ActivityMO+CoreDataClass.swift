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
    
    enum EventCloneOptions {
        case All,
        First,
        Last,
        None
    }
    
    func clone(context:NSManagedObjectContext, eventCloneOptions:ActivityMO.EventCloneOptions) -> ActivityMO {
        let activity = ActivityMO(context: context)
        activity.name = self.name
        activity.isReminderEnabled = self.isReminderEnabled
        activity.interval = self.interval?.clone(context: context)
        activity.reminder = self.reminder?.clone(context: context)
        
        if let history = self.history?.allObjects {
            switch eventCloneOptions {
            case .All:
                for event in history {
                    activity.addToHistory((event as! EventMO).clone(context: context))
                }
            case .First:
                let first = self.firstEvent
                if first != nil {
                    activity.addToHistory(first!.clone(context: context))
                }
            case .Last:
                let last = self.lastEvent
                if last != nil {
                    activity.addToHistory(last!.clone(context: context))
                }
            default:
                break
            }

        }
        return activity
    }
    
    func deleteEvent(event:EventMO) {
        self.removeFromHistory(event)
        if let context = managedObjectContext {
            context.delete(event)
        }
    }

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
        guard let lastDate = lastEvent?.timestamp, let nextDate = self.interval?.getNextDate(since: lastDate) else {
            return false
        }
        return nextDate < Date()
    }
    
    var sortedHistory: [EventMO] {
        return history?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)]) as! [EventMO]
    }
    
    var firstEvent: EventMO? {
        let sorted = sortedHistory
        return sorted.isEmpty ? nil : sorted.first
    }
    
    var firstDate: Date {
        let sortDates = sortedHistory
        return sortDates.isEmpty ? Date() : sortDates[0].timestamp!
    }
    
    var lastEvent: EventMO? {
        let sorted = sortedHistory
        return sorted.isEmpty ? nil : sorted.last
    }
    
    func updateFirstDate(to date:Date) {
        let sortDates = sortedHistory
        guard !sortDates.isEmpty else {
            return
        }
        sortDates[0].timestamp = date
    }
    
//    deinit {
//        print("Destroying an Activity")
//    }
}
