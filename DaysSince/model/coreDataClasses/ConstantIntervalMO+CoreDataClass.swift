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

    override func toPrettyString() -> String {
        return "Every " + String(self.frequency) + " days"
    }

    override func clone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = ConstantIntervalMO(context: context)
        theClone.frequency = self.frequency
        return theClone
    }

}
