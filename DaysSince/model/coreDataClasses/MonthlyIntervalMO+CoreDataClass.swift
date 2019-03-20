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

    override func getNextDate(since lastDate: Date) -> Date? {
        // Construct a new date based on the previous month
        // TODO: Need to consider pushing out a month if the last date was just before the expected date
        let calendar = Calendar.current
        let nextMonthdayDateComponent = DateComponents(day: Int(self.day))
        var nextDate = calendar.nextDate(after: lastDate, matching: nextMonthdayDateComponent, matchingPolicy: .previousTimePreservingSmallerComponents)
        if nextDate != nil {
            nextDate!.normalize()
        }
        return nextDate
    }

    override func toPrettyString() -> String {
        return "Every month on the " + NumberFormatterOrdinal.string(Int(self.day))
    }

    override func clone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = MonthlyIntervalMO(context: context)
        theClone.day = self.day
        return theClone
    }
    
    override func isEquivalent(to other:IntervalMO) -> Bool {
        if !(other is MonthlyIntervalMO) {
            return false
        }
        let monthlyInterval = other as! MonthlyIntervalMO
        return self.day == monthlyInterval.day
    }


}
