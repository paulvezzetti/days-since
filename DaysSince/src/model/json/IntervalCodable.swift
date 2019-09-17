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
    
}
