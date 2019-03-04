//
//  ConstantIntervalMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/28/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ConstantIntervalMO)
public class ConstantIntervalMO: IntervalMO {

    override func getNextDate(since lastDate: Date) -> Date {
        let calendar = Calendar.current
        return calendar.date(byAdding: DateComponents(day: Int(self.frequency)), to: lastDate) ?? lastDate
    }

    override func toPrettyString() -> String {
        return "Every " + String(self.frequency) + " days"
    }

    override func clone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = ConstantIntervalMO(context: context)
        theClone.frequency = self.frequency
        return theClone
    }

}
