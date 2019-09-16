//
//  ActivityCodable.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/10/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

struct ActivityCodable: Codable {
    let uuid: String
    let name: String
    let interval: IntervalCodable
    let events: [EventCodable]
    let reminder: ReminderCodable
    
}
