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
    
    final func getNextDate(since lastDate: Date) -> Date? {
        guard let nextDate = calculateNextDate(since: lastDate, asap: false) else {
            return nil
        }
        if isDateInActiveRange(nextDate) {
            // The next date is in the active range so return it.
            return nextDate
        }
        // Otherwise, we need to find the next available date in the next range window
        // TODO: Warning we could create a situation where the date can never fall in the range (Ex: Do every Feb 1st with a range from May 1 to Jun 1.)
        // We need to handle this, probably by returning nil. Need to figure out how to detect this situation (may need to defer to subclass).
        // Also, we might want to check this when the activity is saved.
        
        
        // Calculate the start of the next active range.
        guard let range = activeRange else {
            return nextDate // Should never get here
        }

        let calendar = Calendar.current
        let startDateComponents = DateComponents(calendar: calendar, timeZone: calendar.timeZone, month: Int(range.startMonth), day: Int(range.startDay))
        guard let activeRangeFirstDate = calendar.nextDate(after: nextDate, matching: startDateComponents, matchingPolicy: .nextTimePreservingSmallerComponents, repeatedTimePolicy: .first, direction: .forward) else {
            return nextDate
        }
        // Move start date back one day so that the search can potentially identify the first day of the range.
        guard let activeRangeStartDate = calendar.date(byAdding: .day, value: -1, to: activeRangeFirstDate) else {
            return nextDate
        }
        // Don't call getNextDate since that could recurse.
        guard let nextDateAfterNextRangeStart = calculateNextDate(since: activeRangeStartDate, asap: true) else {
            return nil
        }
        
        return isDateInActiveRange(nextDateAfterNextRangeStart) ? nextDateAfterNextRangeStart : nil
    }
    
    func calculateNextDate(since lastDate: Date, asap: Bool) -> Date? {
        return nil
    }
    
    func toPrettyString() -> String {
        return "Abstract IntervalMO"
    }
    
    final func clone(context:NSManagedObjectContext) ->IntervalMO {
        let theClone = createClone(context: context)
        if let range = self.activeRange {
            let rangeClone = range.clone(context: context)
            theClone.activeRange = rangeClone
        }

        return theClone
    }
    
    
    func createClone(context:NSManagedObjectContext) -> IntervalMO {
        return IntervalMO(context: context)
    }
    
    func isEquivalent(to other:IntervalMO) -> Bool {
        if let range = self.activeRange {
            return other.activeRange == nil ? false : range.isEquivalent(to: other.activeRange!)
        }
        return other.activeRange == nil
    }
    
    func isDateInActiveRange(_ date:Date) -> Bool {
        guard let range = activeRange else {
            return true
        }
        
        let calendar = Calendar.current
        // First check if the date is exactly equal to the start date before we start looking in the past.
        var specifiedDateComponents = calendar.dateComponents([.year, .timeZone], from: date)
        specifiedDateComponents.month = Int(range.startMonth)
        specifiedDateComponents.day = Int(range.startDay)
        if let rangeStartInSameYear = calendar.date(from: specifiedDateComponents) {
            if date.compare(rangeStartInSameYear) == ComparisonResult.orderedSame {
                return true
            }
        }

        // Find the start date which occurred before the specified date.
        let startDateComponents = DateComponents(calendar: calendar, timeZone: calendar.timeZone, month: Int(range.startMonth), day: Int(range.startDay))
        guard let activeRangeStartDate = calendar.nextDate(after: date, matching: startDateComponents, matchingPolicy: .nextTimePreservingSmallerComponents, repeatedTimePolicy: .first, direction: .backward) else {
            return true
        }
        
        // Find the end of the range that started at the start date
        let endDateComponents = DateComponents(calendar: calendar, timeZone: calendar.timeZone, month: Int(range.endMonth), day: Int(range.endDay))
        guard let activeRangeEndDate = calendar.nextDate(after: activeRangeStartDate, matching: endDateComponents, matchingPolicy: .nextTimePreservingSmallerComponents, repeatedTimePolicy: .first, direction: .forward) else {
            return true
        }
        // If the specified date is less than the end date, then it's okay. We know the start date is before because we only searched in the past.
        return date.compare(activeRangeEndDate) != ComparisonResult.orderedDescending
    }
    
//    deinit {
//        print("Destroying an Interval")
//    }
}
