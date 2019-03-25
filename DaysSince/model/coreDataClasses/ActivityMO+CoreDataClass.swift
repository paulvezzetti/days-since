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
    
    
    enum ActivityState: CaseIterable {
        case VeryOld,
        LastMonth,
        LastWeek,
        Yesterday,
        Today,
        Tomorrow,
        NextWeek,
        NextMonth,
        Future,
        Whenever
        
        func asString() -> String {
            switch self {
            case .VeryOld:
                return "MORE THAN A MONTH OVERDUE"
            case .LastMonth:
                return "DUE LAST MONTH"
            case .LastWeek:
                return "DUE LAST WEEK"
            case .Yesterday:
                return "YESTERDAY"
            case .Today:
                return "TODAY"
            case .Tomorrow:
                return "TOMORROW"
            case .NextWeek:
                return "NEXT WEEK"
            case .NextMonth:
                return "NEXT MONTH"
            case .Future:
                return "FUTURE"
            case . Whenever:
                return "ANY TIME"
            }
        }
    }
    
    var state:ActivityState {
        guard let lastDate = lastEvent?.timestamp, let nextDate = self.interval?.getNextDate(since: lastDate) else {
            return .Whenever
        }
        let calendar = Calendar.current
        let today = Date.normalize(date: Date())
        let daysToNext = calendar.dateComponents([.day], from: today, to: nextDate)
        
        if daysToNext.day == 0 {
            return .Today
        } else if daysToNext.day == 1 {
            return .Tomorrow
        } else if daysToNext.day == -1 {
            return .Yesterday
        } else if daysToNext.day! > 1 && daysToNext.day! <= 7 { // TODO: Should this be week specific Sun-Sat?
            return .NextWeek
        } else if daysToNext.day! > 7 && daysToNext.day! <= 31 { // Should this only include this month
            return .NextMonth
        } else if daysToNext.day! > 31 {
            return .Future
        } else if daysToNext.day! < -1 && daysToNext.day! >= -7 {
            return .LastWeek
        } else if daysToNext.day! < -7 && daysToNext.day! >= 31 {
            return .LastMonth
        }
        return .VeryOld
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
    
    func previousEvent(event:EventMO) -> EventMO? {
        let sorted = sortedHistory
        
        guard let eventIndex = sorted.firstIndex(of: event), eventIndex > 0 else {
            return nil
        }
        return sorted[eventIndex - 1]
    }
    
    func daysSincePreviousEvent(event:EventMO)->Int {
        let sorted = sortedHistory
        
        guard let eventIndex = sorted.firstIndex(of: event), eventIndex > 0 else {
            return -1
        }
        
        let previousEvent = sorted[eventIndex - 1]
        let timeInterval = event.timestamp!.timeIntervalSince(previousEvent.timestamp!)
        
        return Int(timeInterval / (60*60*24))
    }
    
//    deinit {
//        print("Destroying an Activity")
//    }
}
