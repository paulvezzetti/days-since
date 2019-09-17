//
//  ReminderCodable.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/10/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
import CoreData
import Foundation

struct ReminderCodable: Codable {
    
    let enabled: Bool
    let daysBefore: Int16?
    let timeOfDay: Double?
    let allowSnooze: Bool
    let snooze: Int16?
    let lastActualSnooze: Int16?
    let lastSnooze: Double?
    
    
    func toReminderMO(moc:NSManagedObjectContext) -> ReminderMO? {
        let reminder = ReminderMO(context: moc)
        reminder.enabled = enabled
        reminder.daysBefore = daysBefore ?? 1
        reminder.timeOfDay = timeOfDay ?? 0
        reminder.allowSnooze = allowSnooze
        reminder.snooze = snooze ?? 1
        reminder.lastActualSnooze = lastActualSnooze ?? 0
        if let lastSnoozeDouble = lastSnooze {
            reminder.lastSnooze = Date(timeIntervalSinceReferenceDate: lastSnoozeDouble)
        }
        return reminder
    }
}
