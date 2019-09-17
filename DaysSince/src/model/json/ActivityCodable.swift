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
    let interval: IntervalCodable
    let events: [EventCodable]
    let reminder: ReminderCodable
    
    init(uuid:String, name:String, interval:IntervalCodable, events: [EventCodable], reminder: ReminderCodable) {
        self.uuid = uuid
        self.name = name
        self.interval = interval
        self.events = events
        self.reminder = reminder
    }
}
