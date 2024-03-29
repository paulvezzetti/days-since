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
public class ActivityMO: NSManagedObject, AsEncodable {
    
    
    enum EventCloneOptions {
        case All,
        First,
        Last,
        None
    }
    
    func clone(context:NSManagedObjectContext, eventCloneOptions:ActivityMO.EventCloneOptions) -> ActivityMO {
        let activity = ActivityMO(context: context)
        activity.name = self.name
        activity.isPinned = self.isPinned
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
        case Pinned,
        VeryOld,
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
            case .Pinned:
                return NSLocalizedString("activity.state.pinnned", value: "FAVORITES", comment: "")
            case .VeryOld:
                return NSLocalizedString("activity.state.veryOld", value: "MONTH+ OVERDUE", comment: "")
            case .LastMonth:
                return NSLocalizedString("activity.state.lastMonth", value: "DUE LAST MONTH", comment: "")
            case .LastWeek:
                return NSLocalizedString("activity.state.lastWeek", value: "DUE LAST WEEK", comment: "")
            case .Yesterday:
                return NSLocalizedString("activity.state.yesterday", value: "YESTERDAY", comment: "")
            case .Today:
                return NSLocalizedString("activity.state.today", value: "TODAY", comment: "")
            case .Tomorrow:
                return NSLocalizedString("activity.state.tomorrow", value: "TOMORROW", comment: "")
            case .NextWeek:
                return NSLocalizedString("activity.state.nextWeek", value: "NEXT WEEK", comment: "")
            case .NextMonth:
                return NSLocalizedString("activity.state.nextMonth", value: "NEXT MONTH", comment: "")
            case .Future:
                return NSLocalizedString("activity.state.future", value: "FUTURE", comment: "")
            case .Whenever:
                return NSLocalizedString("activity.state.whenever", value: "ANY TIME", comment: "")
            }
        }
    }
    
    var state:ActivityState {
        if isPinned {
            return .Pinned
        }
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
    
    var isOverdue: Bool {
        switch self.state {
        case .Yesterday, .LastWeek, .LastMonth, .VeryOld:
            return true
        default:
            return false
        }
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
    
    
    func asEncodable() -> Codable {
        let uuidValue = id?.uuidString
        let nameValue = name
        var intervalCodable:IntervalCodable?
        if let intervalMO = self.interval {
            intervalCodable = intervalMO.asEncodable() as? IntervalCodable
        }
        var reminderCodable:ReminderCodable?
        if let reminderMO = self.reminder {
            reminderCodable = reminderMO.asEncodable() as? ReminderCodable
        }
        var eventsCodable:[EventCodable] = []
        let history = sortedHistory
        for event in history {
            eventsCodable.append(event.asEncodable() as! EventCodable)
        }
        return ActivityCodable(uuid: uuidValue!, name: nameValue!, isPinned: isPinned, interval: intervalCodable!, events: eventsCodable, reminder: reminderCodable!)
    }
    



//    deinit {
//        print("Destroying an Activity")
//    }
}
