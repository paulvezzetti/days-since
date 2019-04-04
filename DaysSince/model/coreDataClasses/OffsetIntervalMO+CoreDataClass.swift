//
//  OffsetIntervalMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/4/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(OffsetIntervalMO)
public class OffsetIntervalMO: IntervalMO {

    func intervalType() -> OffsetIntervals {
        return .Week
    }
    
    override func isEquivalent(to other:IntervalMO) -> Bool {
        if !(other is OffsetIntervalMO) {
            return false
        }
        let offsetInterval = other as! OffsetIntervalMO
        return self.offset == offsetInterval.offset && self.intervalType() == offsetInterval.intervalType()
    }

}
