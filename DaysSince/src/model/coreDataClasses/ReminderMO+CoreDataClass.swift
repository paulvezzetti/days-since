//
//  ReminderMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/17/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ReminderMO)
public class ReminderMO: NSManagedObject, AsEncodable {
    
    static let REMIND_DAYS_BEFORE_DEFAULT:Int = 0
    static let SNOOZE_FOR_DAYS_DEFAULT:Int = 1

    func clone(context:NSManagedObjectContext) ->ReminderMO {
        let reminder = ReminderMO(context: context)
        reminder.enabled = self.enabled
        reminder.daysBefore = self.daysBefore
        reminder.timeOfDay = self.timeOfDay
        reminder.allowSnooze = self.allowSnooze
        reminder.snooze = self.snooze
        
        return reminder
    }
    
    func isEquivalent(to other:ReminderMO) -> Bool {
        return self.enabled == other.enabled &&
            self.daysBefore == other.daysBefore &&
            self.timeOfDay == other.timeOfDay && 
            self.allowSnooze == other.allowSnooze &&
            self.snooze == other.snooze
        
    }


    func asEncodable() -> Codable {
        return ReminderCodable(enabled: enabled, daysBefore: daysBefore, timeOfDay: timeOfDay, allowSnooze: allowSnooze, snooze: snooze, lastActualSnooze: lastActualSnooze, lastSnooze: lastSnooze?.timeIntervalSinceReferenceDate)
    }

}
