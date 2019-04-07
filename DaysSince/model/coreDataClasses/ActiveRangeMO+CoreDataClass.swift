//
//  ActiveRangeMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/6/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ActiveRangeMO)
public class ActiveRangeMO: NSManagedObject {

    
    func toPrettyString() -> String {
        return "From " + Months.month(for: Int(startMonth)) + " " + String(Int(startDay)) +
        " to " +
            Months.month(for: Int(endMonth)) + " " + String(Int(endDay))
    }
    
    func clone(context:NSManagedObjectContext) -> ActiveRangeMO {
        let theClone = ActiveRangeMO(context: context)
        theClone.startDay = self.startDay
        theClone.startMonth = self.startMonth
        theClone.endDay = self.endDay
        theClone.endMonth = self.endMonth
        
        return theClone
    }

    func isEquivalent(to other:ActiveRangeMO) -> Bool {
        return self.startDay == other.startDay && self.startMonth == other.startMonth && self.endDay == other.endDay && self.endMonth == other.endMonth
    }

    
    static func getStringForNil() -> String {
        return "All Year"
    }
}
