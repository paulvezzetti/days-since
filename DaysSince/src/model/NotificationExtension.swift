//
//  NotificationExtension.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/26/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

extension Notification.Name {
    
    static let activityAdded = Notification.Name("activityAdded")
    static let activityRemoved = Notification.Name("activityRemoved")
    static let activityChanged = Notification.Name("activityChanged")
    static let intervalChanged = Notification.Name("intervalChanged")
    static let eventAdded = Notification.Name("eventAdded")
    static let eventChanged = Notification.Name("eventChanged")
    static let eventRemoved = Notification.Name("eventRemoved")
    static let reminderChanged = Notification.Name("reminderChanged")

    static let showActivity = Notification.Name("showActivity")
    static let snoozeActivity = Notification.Name("snoozeActivity")
        
}
