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

    override func calculateNextDate(since lastDate: Date, asap: Bool) -> Date? {
        let calendar = Calendar.current
        var nextDate = calendar.date(byAdding: DateComponents(day: Int(self.frequency)), to: lastDate)
        if nextDate != nil {
            nextDate!.normalize()
        }
        return nextDate
    }

    override func toPrettyString() -> String {
        return String.localizedStringWithFormat(NSLocalizedString("constantInterval.string", value: "Every %d days", comment: "Ex: Every 5 days"), self.frequency)
    }
    
    override func writeJSON() -> String {
        let typeProp = JSONUtilities.writeProperty(name: "type", property: "Constant")
        let freqProp = JSONUtilities.writeProperty(name: "frequency", property: self.frequency)
        return "\(typeProp), \(freqProp)"
    }

    override func createClone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = ConstantIntervalMO(context: context)
        theClone.frequency = self.frequency
        return theClone
    }

    override func isEquivalent(to other:IntervalMO) -> Bool {
        if !(other is ConstantIntervalMO) || !super.isEquivalent(to: other) {
            return false
        }
        let constantInterval = other as! ConstantIntervalMO
        return self.frequency == constantInterval.frequency
    }

}
