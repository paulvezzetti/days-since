//
//  WeekOffsetIntervalMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/4/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(WeekOffsetIntervalMO)
public class WeekOffsetIntervalMO: OffsetIntervalMO {

    static let TYPE:String = "weekOffset"
    
    var weeks: Int16 {
        get {
            return self.offset
        }
        set(week) {
            self.offset = week
        }
    }
    
    override func intervalType() -> OffsetIntervals {
        return .Week
    }

    override func calculateNextDate(since lastDate: Date, asap: Bool) -> Date? {
        return Calendar.current.date(byAdding: .day, value: Int(self.weeks) * 7, to: lastDate)
    }
    
    override func toPrettyString() -> String {
        return String.localizedStringWithFormat(NSLocalizedString("weekOffset.string", comment: ""), Int(self.weeks))
    }
    
    
    override func asEncodable() -> Codable {
        return IntervalCodable(type: WeekOffsetIntervalMO.TYPE, activeRange: getActiveRangeCodable(), day: nil, week: self.weeks, month: nil, year: nil)
    }


    override func createClone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = WeekOffsetIntervalMO(context: context)
        theClone.weeks = self.weeks
        return theClone
        
    }
    
}
