//
//  MonthOffsetIntervalMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/4/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MonthOffsetIntervalMO)
public class MonthOffsetIntervalMO: OffsetIntervalMO {

    var months:Int16 {
        get {
            return self.offset
        }
        set(month) {
            self.offset = month
        }
    }
    
    override func intervalType() -> OffsetIntervals {
        return .Month
    }
    
    override func getNextDate(since lastDate: Date) -> Date? {
        return Calendar.current.date(byAdding: .month, value: Int(self.months), to: lastDate)
    }
    
    override func toPrettyString() -> String {
        return self.months == 1 ? "Every Month" : "Every " + String(self.months) + " months"
    }
    
    override func clone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = MonthOffsetIntervalMO(context: context)
        theClone.months = self.months
        return theClone

    }
    

}
