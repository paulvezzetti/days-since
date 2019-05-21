//
//  UnlimitedIntervalMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/28/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(UnlimitedIntervalMO)
public class UnlimitedIntervalMO: IntervalMO {

    override func calculateNextDate(since lastDate: Date, asap: Bool) -> Date? {
        return nil
    }
    
    override func toPrettyString() -> String {
        return NSLocalizedString("unlimitedInterval.string", value: "Whenever I feel like it", comment: "") 
    }

    override func createClone(context:NSManagedObjectContext) ->IntervalMO {
        return UnlimitedIntervalMO(context: context)
    }

    override func isEquivalent(to other:IntervalMO) -> Bool {
        return other is UnlimitedIntervalMO ?  super.isEquivalent(to: other) : false
    }

}