//
//  WeekOffsetIntervalMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/4/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(WeekOffsetIntervalMO)
public class WeekOffsetIntervalMO: OffsetIntervalMO {

    var weeks: Int16 {
        get {
            return self.offset
        }
        set(week) {
            self.offset = week
        }
    }
    
    override func intervalType() -> OffsetIntervals {
        return .Week
    }

    override func getNextDate(since lastDate: Date) -> Date? {
        return Calendar.current.date(byAdding: .day, value: Int(self.weeks) * 7, to: lastDate)
    }
    
    override func toPrettyString() -> String {
        return self.weeks == 1 ? "Every Week" : "Every " + String(self.weeks) + " weeks"
    }
    
    override func clone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = WeekOffsetIntervalMO(context: context)
        theClone.weeks = self.weeks
        return theClone
        
    }
    
}
