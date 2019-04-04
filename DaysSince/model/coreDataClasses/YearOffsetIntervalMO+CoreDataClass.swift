//
//  YearOffsetIntervalMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/4/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(YearOffsetIntervalMO)
public class YearOffsetIntervalMO: IntervalMO {

    override func getNextDate(since lastDate: Date) -> Date? {
        return Calendar.current.date(byAdding: .year, value: Int(self.years), to: lastDate)
    }
    
    override func toPrettyString() -> String {
        return self.years == 1 ? "Every year" : "Every " + String(self.years) + " years"
    }
    
    override func clone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = YearOffsetIntervalMO(context: context)
        theClone.years = self.years
        return theClone
        
    }
    
    override func isEquivalent(to other:IntervalMO) -> Bool {
        if !(other is YearOffsetIntervalMO) {
            return false
        }
        let yearOffsetInterval = other as! YearOffsetIntervalMO
        return self.years == yearOffsetInterval.years
    }

}
