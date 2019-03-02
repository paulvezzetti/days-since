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

    override func toPrettyString() -> String {
        return "Every week on " + DaysOfWeek.fromIndex(Int(self.day)).rawValue
    }
    
    override func clone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = WeeklyIntervalMO(context: context)
        theClone.day = self.day
        return theClone
    }

}
