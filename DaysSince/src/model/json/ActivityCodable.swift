//
//  ActivityCodable.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/10/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

class ActivityCodable: Codable {
    let uuid: String
    let name: String
    let isPinned: Bool
    let interval: IntervalCodable
    let events: [EventCodable]
    let reminder: ReminderCodable
    
    init(uuid:String, name:String, isPinned:Bool, interval:IntervalCodable, events: [EventCodable], reminder: ReminderCodable) {
        self.uuid = uuid
        self.name = name
        self.isPinned = isPinned
        self.interval = interval
        self.events = events
        self.reminder = reminder
    }
}
