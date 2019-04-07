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

    override func calculateNextDate(since lastDate: Date) -> Date? {
        // Construct a new date based on the previous.
        // TODO: Need to consider how close we are to the expected date to know if we need to push to
        // the next year.
        let calendar = Calendar.current
        let nextYearDayDateComponent = DateComponents(month: Int(self.month), day: Int(self.day))
        var nextDate = calendar.nextDate(after: lastDate, matching: nextYearDayDateComponent, matchingPolicy: .nextTimePreservingSmallerComponents)
        if nextDate != nil {
            nextDate!.normalize()
            // Allow for a 90 day grace period for early events
            // TODO: Add these grace period numbers to a global settings
            let daysComponent = calendar.dateComponents([.day], from: lastDate, to: nextDate!)
            if daysComponent.day! <= 90 {
                nextDate = calendar.nextDate(after: nextDate!, matching: nextYearDayDateComponent, matchingPolicy: .nextTime)
            }

        }
        return nextDate
    }

    
    override func toPrettyString() -> String {
        return "Every year on " + Months.month(for: Int(self.month)) + " " + String(day)
    }

    override func createClone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = YearlyIntervalMO(context: context)
        theClone.day = self.day
        theClone.month = self.month
        return theClone
    }

    override func isEquivalent(to other:IntervalMO) -> Bool {
        if !(other is YearlyIntervalMO) || !super.isEquivalent(to: other) {
            return false
        }
        let yearlyInterval = other as! YearlyIntervalMO
        return self.day == yearlyInterval.day && self.month == yearlyInterval.month
    }

}
