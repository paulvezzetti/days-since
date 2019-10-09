//
//  IntervalCodable.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/10/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation
import CoreData

class IntervalCodable: Codable {
    let type: String
    let activeRange: ActiveRangeCodable?
    
    let day: Int16?
    let week: Int16?
    let month: Int16?
    let year: Int16?
    
    init(type:String, activeRange:ActiveRangeCodable?, day:Int16?, week: Int16?, month:Int16?, year:Int16?) {
        self.type = type
        self.activeRange = activeRange
        self.day = day
        self.week = week
        self.month = month
        self.year = year
    }
    
    func toIntervalMO(moc:NSManagedObjectContext) -> IntervalMO? {
        var intervalMO:IntervalMO? = nil
        switch type {
        case ConstantIntervalMO.TYPE:
            intervalMO = ConstantIntervalMO(context: moc)
            (intervalMO as! ConstantIntervalMO).frequency = day ?? 1
        case MonthlyIntervalMO.TYPE:
            intervalMO = MonthlyIntervalMO(context: moc)
            (intervalMO as! MonthlyIntervalMO).day = day ?? 1
        case MonthOffsetIntervalMO.TYPE:
            intervalMO = MonthOffsetIntervalMO(context: moc)
            (intervalMO as! MonthOffsetIntervalMO).months = month ?? 1
        case UnlimitedIntervalMO.TYPE:
            intervalMO = UnlimitedIntervalMO(context: moc)
        case WeeklyIntervalMO.TYPE:
            intervalMO = WeeklyIntervalMO(context: moc)
            (intervalMO as! WeeklyIntervalMO).day = day ?? 1
        case WeekOffsetIntervalMO.TYPE:
            intervalMO = WeekOffsetIntervalMO(context: moc)
            (intervalMO as! WeekOffsetIntervalMO).weeks = week ?? 1
        case YearlyIntervalMO.TYPE:
            intervalMO = YearlyIntervalMO(context: moc)
            (intervalMO as! YearlyIntervalMO).day = day ?? 1
            (intervalMO as! YearlyIntervalMO).month = month ?? 1
        case YearOffsetIntervalMO.TYPE:
            intervalMO = YearOffsetIntervalMO(context: moc)
            (intervalMO as! YearOffsetIntervalMO).years = year ?? 1
        default:
            intervalMO = UnlimitedIntervalMO(context: moc)
        }
        
        if let range = activeRange {
            intervalMO?.activeRange = range.toActiveRangeMO(moc: moc)
        }
        
        return intervalMO
    }
    
    func toPrettyString() -> String {
        var pretty:String? = nil
        switch type {
        case ConstantIntervalMO.TYPE:
            pretty = String.localizedStringWithFormat(NSLocalizedString("constantInterval.string", value: "Every %d days", comment: "Ex: Every 5 days"), day ?? 1)
        case MonthlyIntervalMO.TYPE:
            pretty = String.localizedStringWithFormat(NSLocalizedString("monthlyInterval.string", value: "Every month on the %@", comment: "Ex: Every month on the 12th"), NumberFormatterOrdinal.string(Int(day ?? 1)))
        case MonthOffsetIntervalMO.TYPE:
            pretty = String.localizedStringWithFormat(NSLocalizedString("monthOffset.string", comment: ""), Int(month ?? 1))
        case UnlimitedIntervalMO.TYPE:
            pretty = NSLocalizedString("unlimitedInterval.string", value: "Whenever I feel like it", comment: "") 
        case WeeklyIntervalMO.TYPE:
            pretty = String.localizedStringWithFormat(NSLocalizedString("weeklyInterval.string", value: "Every week on %@", comment: "Ex: Every week on Tuesday"), Weekdays.day(for: Int(day ?? 1)))
        case WeekOffsetIntervalMO.TYPE:
            pretty = String.localizedStringWithFormat(NSLocalizedString("weekOffset.string", comment: ""), Int(week ?? 1))
        case YearlyIntervalMO.TYPE:
            pretty = String.localizedStringWithFormat(NSLocalizedString("yearlyInterval.string", value: "Every year on %@ %d", comment: "Ex: Every year on Jan 15"), Months.month(for: Int(month ?? 1)), day ?? 1)
        case YearOffsetIntervalMO.TYPE:
            pretty = String.localizedStringWithFormat(NSLocalizedString("yearOffset.string", comment: ""), Int(year ?? 1))
        default:
            pretty = ""
        }
        return pretty ?? ""
    }
    
}
