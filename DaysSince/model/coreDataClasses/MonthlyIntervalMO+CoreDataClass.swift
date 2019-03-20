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
        let calendar = Calendar.current
        let nextMonthdayDateComponent = DateComponents(day: Int(self.day))
        var nextDate = calendar.nextDate(after: lastDate, matching: nextMonthdayDateComponent, matchingPolicy: .previousTimePreservingSmallerComponents)
        if nextDate != nil {
            nextDate!.normalize()
            // Allow for a 10 day grace period for early events
            let daysComponent = calendar.dateComponents([.day], from: lastDate, to: nextDate!)
            if daysComponent.day! <= 10 {
                nextDate = calendar.nextDate(after: nextDate!, matching: nextMonthdayDateComponent, matchingPolicy: .previousTimePreservingSmallerComponents)
            }
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
