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
        // Construct a new date based on the previous.
        // TODO: Need to consider how close we are to the expected date to know if we need to push to
        // the next year.
        let calendar = Calendar.current
        let nextYearDayDateComponent = DateComponents(month: Int(self.month), day: Int(self.day))
        let nextDate = calendar.nextDate(after: lastDate, matching: nextYearDayDateComponent, matchingPolicy: .nextTime)
        
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
