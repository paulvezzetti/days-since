//
//  YearlyIntervalMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/28/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(YearlyIntervalMO)
public class YearlyIntervalMO: IntervalMO {

    override func getNextDate(since lastDate: Date) -> Date {
        // Construct a new date based on the previous week
        let calendar = Calendar.current
        var nextDate = calendar.date(bySetting: .month, value: Int(self.month), of: lastDate)
        if nextDate != nil {
            nextDate = calendar.date(bySetting: .day, value: Int(self.day), of: nextDate!)
            if nextDate != nil {
                nextDate = calendar.date(byAdding: DateComponents(year: 1), to: nextDate!)
            }
        }
        
        let nextYearDayDateComponent = DateComponents(month: Int(self.month), day: Int(self.day))
        let maybeNextDate = calendar.nextDate(after: lastDate, matching: nextYearDayDateComponent, matchingPolicy: .nextTime)
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        
        print("Using calendar: \(formatter.string(from: maybeNextDate!))")
        print("Using my calc : \(formatter.string(from: nextDate!))")

        return nextDate ?? Date()
    }

    
    override func toPrettyString() -> String {
        return "Every year on " + Months.month(for: Int(self.month)) + " " + String(day)
    }

    override func clone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = YearlyIntervalMO(context: context)
        theClone.day = self.day
        theClone.month = self.month
        return theClone
    }

}
