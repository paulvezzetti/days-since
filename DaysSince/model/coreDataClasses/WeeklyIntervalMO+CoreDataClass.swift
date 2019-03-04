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
