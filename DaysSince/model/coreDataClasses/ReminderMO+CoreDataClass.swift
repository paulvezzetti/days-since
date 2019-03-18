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
public class ReminderMO: NSManagedObject {

    func clone(context:NSManagedObjectContext) ->ReminderMO {
        let reminder = ReminderMO(context: context)
        reminder.enabled = self.enabled
        reminder.daysBefore = self.daysBefore
        reminder.allowSnooze = self.allowSnooze
        reminder.snooze = self.snooze
        
        return reminder
    }
    
    func isEquivalent(to other:ReminderMO) -> Bool {
        return self.enabled == other.enabled &&
            self.daysBefore == other.daysBefore &&
            self.allowSnooze == other.allowSnooze &&
            self.snooze == other.snooze
        
    }

}
