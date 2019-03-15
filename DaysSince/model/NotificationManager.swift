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
            guard let userInfo = notification.userInfo else { return }

            if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
                //print("--- INSERTS ---")
                //print(inserts)
                //print("+++++++++++++++")
                for mo in inserts {
                    if let activity = mo as? ActivityMO {
                        scheduleReminderNotification(for: activity)
                  //      print("Inserted activity \(activity.name!)")
                    } //else if let event = mo as? EventMO {
                  //      print("Inserted event \(event.timestamp!)")
                  //  }
                }
            }

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
        
        let uuid = activity.id!.uuidString
        let content = UNMutableNotificationContent()
        // TODO: Need to figure out the content to display
        // title = Activity Name
        // subtitle = Status of activity (ex: Activity is 10 days overdue or Activity is due tomorrow.
        // body = Longer description of the activity status (e.g. Last completed, Next due, Frequency, Avg interval, etc.
        // badge = Total number of activities that are overdue
        // userInfo : Probably need to include at least the activity uuid
        
        let stats:ActivityStatistics = ActivityStatistics(activity: activity)
        content.title = activity.name ?? "Activity"
        content.subtitle = "Subtitle"
        content.body = "Next due date: " + stats.nextDay
        
        content.userInfo = ["UUID": uuid]
        
        // Set the category identifier
        content.categoryIdentifier = ACTIVITY_CATEGORY_ID
        // Set the thread identifier to the UUID of the Activity so they are grouped together
        content.threadIdentifier = uuid
        
        // Set up the trigger.
        // TODO: This should be a UNCalendarNotificationTrigger which is based off of the next notification date
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 30, repeats: false)
        // Create the request
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        notificationCenter.add(request) {
            (error) in
            if error != nil {
                print("Unable to add notification request" + error!.localizedDescription)
            }
        }
        
    }
    
    
}

extension NotificationManager : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
    }
    
}
