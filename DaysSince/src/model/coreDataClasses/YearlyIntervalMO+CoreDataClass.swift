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

    override func calculateNextDate(since lastDate: Date, asap: Bool) -> Date? {
        // Construct a new date based on the previous.
        // TODO: Need to consider how close we are to the expected date to know if we need to push to
        // the next year.
        let calendar = Calendar.current
        let nextYearDayDateComponent = DateComponents(month: Int(self.month), day: Int(self.day))
        var nextDate = calendar.nextDate(after: lastDate, matching: nextYearDayDateComponent, matchingPolicy: .nextTimePreservingSmallerComponents)
        if nextDate != nil {
            nextDate!.normalize()
            // Allow for a 90 day grace period for early events but only if it is not a request for the earliest possible date.
            // TODO: Add these grace period numbers to a global settings
            if !asap {
                let daysComponent = calendar.dateComponents([.day], from: lastDate, to: nextDate!)
                if daysComponent.day! <= 90 {
                    nextDate = calendar.nextDate(after: nextDate!, matching: nextYearDayDateComponent, matchingPolicy: .nextTime)
                }
            }
        }
        return nextDate
    }

    
    override func toPrettyString() -> String {
        return String.localizedStringWithFormat(NSLocalizedString("yearlyInterval.string", value: "Every year on %@ %d", comment: "Ex: Every year on Jan 15"), Months.month(for: Int(self.month)), day)
    }

    override func writeJSON() -> String {
        let typeProp = JSONUtilities.writeProperty(name: "type", property: "Yearly")
        let monthProp = JSONUtilities.writeProperty(name: "month", property: self.month)
        let dayProp = JSONUtilities.writeProperty(name: "day", property: self.day)
        return "\(typeProp), \(monthProp), \(dayProp)"
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
