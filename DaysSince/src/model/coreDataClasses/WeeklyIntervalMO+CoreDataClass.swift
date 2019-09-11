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

    override func calculateNextDate(since lastDate: Date, asap: Bool) -> Date? {
        // Construct a new date based on the previous week
        let calendar = Calendar.current
        // This seems to work well and relies on standard library code.
        // TODO: Need to consider if the next date comes out to be in the same week
        // as the last date, we may want to advance to the next week. Ex: If it is
        // done on Tuesday, but due on Wednesdays, it should really push out 8 days not 1.
        let nextWeekdayDateComponent = DateComponents(weekday: Int(self.day))
        var nextDate = calendar.nextDate(after: lastDate, matching: nextWeekdayDateComponent, matchingPolicy: .nextTime)
        if nextDate != nil {
            nextDate!.normalize()
            // Any time in the last week counts as this "week" so advance if it's been done.
            if !asap {
                let daysComponent = calendar.dateComponents([.day], from: lastDate, to: nextDate!)
                if daysComponent.day! < 7 {
                    nextDate = calendar.nextDate(after: nextDate!, matching: nextWeekdayDateComponent, matchingPolicy: .nextTime)
                }
            }
        }
        
        return nextDate
    }

    
    override func toPrettyString() -> String {
        return String.localizedStringWithFormat(NSLocalizedString("weeklyInterval.string", value: "Every week on %@", comment: "Ex: Every week on Tuesday"), Weekdays.day(for: Int(self.day)))
    }
    
    
    override func writeToJSON(writer: JSONWriter) {
        super.writeToJSON(writer: writer)
        writer.addProperty(name: "type", property: "weekly")
        writer.addProperty(name: "day", property: self.day)
    }


    override func createClone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = WeeklyIntervalMO(context: context)
        theClone.day = self.day
        return theClone
    }
    
    override func isEquivalent(to other:IntervalMO) -> Bool {
        if !(other is WeeklyIntervalMO) || !super.isEquivalent(to: other) {
            return false
        }
        let weeklyInterval = other as! WeeklyIntervalMO
        return self.day == weeklyInterval.day
    }


}
