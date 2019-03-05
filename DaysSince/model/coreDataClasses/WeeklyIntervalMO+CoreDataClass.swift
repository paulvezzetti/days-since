//
//  WeeklyIntervalMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/28/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(WeeklyIntervalMO)
public class WeeklyIntervalMO: IntervalMO {

    override func getNextDate(since lastDate: Date) -> Date {
        // Construct a new date based on the previous week
        let calendar = Calendar.current
        var nextDate = calendar.date(bySetting: .weekday, value: Int(self.day), of: lastDate)
        if nextDate != nil {
            nextDate = calendar.date(byAdding: DateComponents(weekOfYear: 1), to: nextDate!)
        }
        
        // This seems to work well and relies on standard library code.
        // TODO: Need to consider if the next date comes out to be in the same week
        // as the last date, we may want to advance to the next week. Ex: If it is
        // done on Tuesday, but due on Wednesdays, it should really push out 8 days not 1.
        let nextWeekdayDateComponent = DateComponents(weekday: Int(self.day))
        let maybeNextDate = calendar.nextDate(after: lastDate, matching: nextWeekdayDateComponent, matchingPolicy: .nextTime)
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none

        print("Using calendar: \(formatter.string(from: maybeNextDate!))")
        print("Using my calc : \(formatter.string(from: nextDate!))")

        return nextDate ?? Date()
    }

    
    override func toPrettyString() -> String {
        return "Every week on " + Weekdays.day(for: Int(self.day))
    }
    
    override func clone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = WeeklyIntervalMO(context: context)
        theClone.day = self.day
        return theClone
    }

}
