//
//  IntervalMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/28/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(IntervalMO)
public class IntervalMO: NSManagedObject {
    
    func toPrettyString() -> String {
        return "Abstact IntervalMO"
    }
    
    func clone(context:NSManagedObjectContext) ->IntervalMO {
        return IntervalMO(context: context)
    }
}
