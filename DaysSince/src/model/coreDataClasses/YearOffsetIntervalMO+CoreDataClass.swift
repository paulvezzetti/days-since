//
//  YearOffsetIntervalMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/4/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(YearOffsetIntervalMO)
public class YearOffsetIntervalMO: OffsetIntervalMO {

    static let TYPE:String = "yearOffset"
    
    var years: Int16 {
        get {
            return self.offset
        }
        set(year) {
            self.offset = year
        }
    }
    
    override func intervalType() -> OffsetIntervals {
        return .Year
    }

    override func calculateNextDate(since lastDate: Date, asap: Bool) -> Date? {
        return Calendar.current.date(byAdding: .year, value: Int(self.years), to: lastDate)
    }
    
    override func toPrettyString() -> String {
        return String.localizedStringWithFormat(NSLocalizedString("yearOffset.string", comment: ""), Int(self.years))
    }
    
    override func asEncodable() -> Codable {
        return IntervalCodable(type: YearOffsetIntervalMO.TYPE, activeRange: getActiveRangeCodable(), day: nil, week: nil, month: nil, year: self.years)
    }
    
    override func createClone(context:NSManagedObjectContext) -> IntervalMO {
        let theClone = YearOffsetIntervalMO(context: context)
        theClone.years = self.years
        return theClone
        
    }
    

}
