//
//  ReminderCodable.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/10/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

struct ReminderCodable: Codable {
    
    let enabled: Bool
    let daysBefore: Int16?
    let timeOfDay: Double?
    let allowSnooze: Bool
    let snooze: Int16?
    let lastActualSnooze: Int16?
    let lastSnooze: Double?
    
}
