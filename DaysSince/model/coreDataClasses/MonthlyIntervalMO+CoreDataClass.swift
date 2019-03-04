//
//  MonthlyIntervalMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/28/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MonthlyIntervalMO)
public class MonthlyIntervalMO: IntervalMO {

    override func getNextDate(since lastDate: Date) -> Date {
        // Construct a new date based on the previous month
        let calendar = Calendar.current
        var nextDate = calendar.date(bySetting: .day, value: Int(self.day), of: lastDate)
        if nextDate != nil {
            nextDate = calendar.date(byAdding: DateComponents(month: 1), to: nextDate!)
        }
        return nextDate ?? Date()
    }

    override func toPrettyString() -> String {
        return "Every month on the " + String(self.day)
    }

    override func clone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = MonthlyIntervalMO(context: context)
        theClone.day = self.day
        return theClone
    }

}
