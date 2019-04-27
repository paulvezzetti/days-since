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
        return ActiveRangeMO.formatAsRange(startMonth: Int(startMonth), startDay: Int(startDay), endMonth: Int(endMonth), endDay: Int(endDay))
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
        return NSLocalizedString("allYear", value: "All Year", comment: "")
    }
    
    static func formatAsRange(startMonth: Int, startDay:Int, endMonth: Int, endDay: Int) -> String {
        return String.localizedStringWithFormat(NSLocalizedString("dateRange.label", value: "From %@ %d to %@ %d", comment: "Labels a date range. Ex: From Jan 5 to Feb 15"), Months.month(for: startMonth), startDay, Months.month(for: endMonth), endDay)
    }
}
