//
//  NotificationManager.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/14/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
import CoreData
import Foundation
import UserNotifications

class NotificationManager : NSObject {
    
    private let ACTIVITY_CATEGORY_ID:String = "DAYS_SINCE_ACTIVITY_CATEGORY"
    
    private enum NotificationActions: String {
        case MARK_DONE, SNOOZE
    }
    
    private let dataManager:DataModelManager
    private let notificationCenter = UNUserNotificationCenter.current()
    
    
    init(dataManager:DataModelManager) {
        self.dataManager = dataManager

        super.init()
        // Register as a delegate
        notificationCenter.delegate = self
        // Register the notification actions for 'mark done' and 'snooze'
        let markDoneAction = UNNotificationAction(identifier: NotificationActions.MARK_DONE.rawValue, title: "Mark Done", options: UNNotificationActionOptions(rawValue: 0))
        let snoozeAction = UNNotificationAction(identifier: NotificationActions.SNOOZE.rawValue, title: "Snooze", options: UNNotificationActionOptions(rawValue: 0))
        let daysSinceCategory = UNNotificationCategory(identifier: ACTIVITY_CATEGORY_ID, actions: [markDoneAction, snoozeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: UNNotificationCategoryOptions(rawValue: 0))
        // Set the notification category
        notificationCenter.setNotificationCategories([daysSinceCategory])
        
        // Register for changes to the data model so we can schedule the notifications
        do {
            let context = try dataManager.getManagedObjectContext()
            let notificationCenter = NotificationCenter.default
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextWillSave), name: NSNotification.Name.NSManagedObjectContextWillSave, object: context)
            notificationCenter.addObserver(self, selector: #selector(managedObjectContextDidSave), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
        } catch {
            
        }
    }
    
    

    @objc
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
//            guard let userInfo = notification.userInfo else { return }
//
//            if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
//                print("--- INSERTS ---")
//                print(inserts)
//                print("+++++++++++++++")
//                for mo in inserts {
//                    if let activity = mo as? ActivityMO {
//                        print("Inserted activity \(activity.name!)")
//                    } else if let event = mo as? EventMO {
//                        print("Inserted event \(event.timestamp!)")
//                    }
//                }
//            }
//
//            if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
//                print("--- UPDATES ---")
//                for update in updates {
//                    print(update.changedValues())
//                }
//                print("+++++++++++++++")
//            }
//
//            if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
//                print("--- DELETES ---")
//                print(deletes)
//                print("+++++++++++++++")
//            }
    }
    
    @objc
    func managedObjectContextWillSave(notification: NSNotification) {

    }
    
    @objc
    func managedObjectContextDidSave(notification: NSNotification) {

    }
    
    func scheduleReminderNotification(for activity:ActivityMO) {
        
    }
    
    
}

extension NotificationManager : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
    
}
