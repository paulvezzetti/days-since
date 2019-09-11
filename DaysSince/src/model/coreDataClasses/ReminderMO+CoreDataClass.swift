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
public class ReminderMO: NSManagedObject, JSONWritable {
    
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

   
    func writeToJSON(writer: JSONWriter) {
        writer.addProperty(name: "enabled", property: enabled)
        writer.addProperty(name: "daysBefore", property: daysBefore)
        writer.addProperty(name: "timeOfDay", property: timeOfDay)
        writer.addProperty(name: "allowSnooze", property: allowSnooze)
        writer.addProperty(name: "snooze", property: snooze)
        writer.addProperty(name: "lastActualSnooze", property: lastActualSnooze)
        if let lastSnoozeDate = lastSnooze {
            writer.addProperty(name: "lastSnooze", property: lastSnoozeDate.timeIntervalSinceReferenceDate)
        }
    }

}
