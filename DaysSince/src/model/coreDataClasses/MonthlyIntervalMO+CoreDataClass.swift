//
//  MonthlyIntervalMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/28/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(MonthlyIntervalMO)
public class MonthlyIntervalMO: IntervalMO {

    override func calculateNextDate(since lastDate: Date, asap: Bool) -> Date? {
        // Construct a new date based on the previous month
        let calendar = Calendar.current
        let nextMonthdayDateComponent = DateComponents(day: Int(self.day))
        var nextDate = calendar.nextDate(after: lastDate, matching: nextMonthdayDateComponent, matchingPolicy: .previousTimePreservingSmallerComponents)
        if nextDate != nil {
            nextDate!.normalize()
            // Allow for a 10 day grace period for early events
            if !asap {
                let daysComponent = calendar.dateComponents([.day], from: lastDate, to: nextDate!)
                if daysComponent.day! <= 10 {
                    nextDate = calendar.nextDate(after: nextDate!, matching: nextMonthdayDateComponent, matchingPolicy: .previousTimePreservingSmallerComponents)
                }
            }
        }
        return nextDate
    }

    override func toPrettyString() -> String {
        return String.localizedStringWithFormat(NSLocalizedString("monthlyInterval.string", value: "Every month on the %@", comment: "Ex: Every month on the 12th"), NumberFormatterOrdinal.string(Int(self.day)))
    }
    
    override func asEncodable() -> Codable {
        return IntervalCodable(type: "monthly", activeRange: getActiveRangeCodable(), day: self.day, week: nil, month: nil, year: nil)
    }

    
    override func createClone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = MonthlyIntervalMO(context: context)
        theClone.day = self.day
        return theClone
    }
    
    override func isEquivalent(to other:IntervalMO) -> Bool {
        if !(other is MonthlyIntervalMO) || !super.isEquivalent(to: other) {
            return false
        }
        let monthlyInterval = other as! MonthlyIntervalMO
        return self.day == monthlyInterval.day
    }


}
