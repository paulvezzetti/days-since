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

    override func getNextDate(since lastDate: Date) -> Date {
        return Date.distantFuture
    }
    
    override func toPrettyString() -> String {
        return "Whenever I feel like it"
    }

    override func clone(context:NSManagedObjectContext) ->IntervalMO {
        return UnlimitedIntervalMO(context: context)
    }

}
