//
//  NotificationMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/4/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(NotificationMO)
public class NotificationMO: NSManagedObject {

    
    func clone(context:NSManagedObjectContext) ->NotificationMO {
        let notification = NotificationMO(context: context)
        notification.enabled = self.enabled
        notification.daysBefore = self.daysBefore
        notification.allowSnooze = self.allowSnooze
        notification.snooze = self.snooze
        
        return notification
    }
    
    func isEquivalent(to other:NotificationMO) -> Bool {
        return self.enabled == other.enabled &&
            self.daysBefore == other.daysBefore &&
            self.allowSnooze == other.allowSnooze &&
            self.snooze == other.snooze
        
    }

}
