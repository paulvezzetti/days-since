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

    static let TYPE:String = "monthOffset"

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
    
    override func calculateNextDate(since lastDate: Date, asap: Bool) -> Date? {
        return Calendar.current.date(byAdding: .month, value: Int(self.months), to: lastDate)
    }
    
    override func toPrettyString() -> String {
        return String.localizedStringWithFormat(NSLocalizedString("monthOffset.string", comment: ""), Int(self.months))
    }
    
    override func asEncodable() -> Codable {
        return IntervalCodable(type: MonthOffsetIntervalMO.TYPE, activeRange: getActiveRangeCodable(), day: nil, week: nil, month: self.months, year: nil)
    }

    
    override func createClone(context: NSManagedObjectContext) -> IntervalMO {
        let theClone = MonthOffsetIntervalMO(context: context)
        theClone.months = self.months
        return theClone
    }
    

}
