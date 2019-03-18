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
    
    private let DONE_ONLY_CATEGORY_ID:String = "DAYS_SINCE_DONE_CATEGORY"
    private let DONE_AND_SNOOZE_CATEGORY_ID:String = "DAYS_SINCE_DONE_SNOOZE_CATEGORY"

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
        let doneCategory = UNNotificationCategory(identifier: DONE_ONLY_CATEGORY_ID, actions: [markDoneAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: UNNotificationCategoryOptions(rawValue: 0))
        let doneAndSnoozeCategory = UNNotificationCategory(identifier: DONE_AND_SNOOZE_CATEGORY_ID, actions: [markDoneAction, snoozeAction], intentIdentifiers: [], hiddenPreviewsBodyPlaceholder: "", options: UNNotificationCategoryOptions(rawValue: 0))
        // Set the notification category
        notificationCenter.setNotificationCategories([doneCategory, doneAndSnoozeCategory])
        
        // Register for changes to the data model so we can schedule the notifications
        NotificationCenter.default.addObserver(self, selector: #selector(activityAdded(notification:)), name: Notification.Name.activityAdded, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(activityRemoved(notification:)), name: Notification.Name.activityRemoved, object: nil)

        //        do {
//            let context = try dataManager.getManagedObjectContext()
//            let notificationCenter = NotificationCenter.default
//            notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: context)
//            notificationCenter.addObserver(self, selector: #selector(managedObjectContextWillSave), name: NSNotification.Name.NSManagedObjectContextWillSave, object: context)
//            notificationCenter.addObserver(self, selector: #selector(managedObjectContextDidSave), name: NSNotification.Name.NSManagedObjectContextDidSave, object: context)
//        } catch {
//
//        }
    }
    
    @objc func activityAdded(notification: Notification ) {
        guard let activity = notification.object as? ActivityMO else {
            return
        }
        scheduleReminderNotification(for: activity)
    }

    @objc func activityRemoved(notification: Notification ) {
        guard let activity = notification.object as? ActivityMO else {
            return
        }
        removeAllPendingNotifications(for: activity)
    }

    /* ----------------------------------------------------------
     What is the logic for setting up our reminders.
     - if reminders are enabled:
     - When a new activity is created:
        - Calculate the time to the next event
        - Subtract the time before for the reminder
        - Schedule the notification for that time
     - When an activity interval is modified
        - Remove all pending notifications
        - Schedule a new notification just like this was an existing activity
     - When an activity's history changes (either a new event or an event is removed)
        - Remove all pending notifications
        - Schedule a new notification just like this was an existing activity
     - When the user 'snoozes' an activity.
        - Remove all pending notifications (there shouldn't be any)
        - Schedule a new snooze notification based on 'now' plus 'snooze'
 
       ---------------------------------------------------------- */

    
    func scheduleReminderNotification(for activity:ActivityMO) {
        let uuid = activity.id!.uuidString
        guard activity.reminder!.enabled else {
            // If this activity is not enabled for notifications, then yank any pending notifications from
            // the notification center. It's not likely.
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
            return
        }
        print("Scheduling reminder for activity: \(activity.name ?? "") with uuid: \(uuid) ")
        let content = UNMutableNotificationContent()
        // TODO: Need to figure out the content to display
        // title = Activity Name
        // subtitle = Status of activity (ex: Activity is 10 days overdue or Activity is due tomorrow.
        // body = Longer description of the activity status (e.g. Last completed, Next due, Frequency, Avg interval, etc.
        // badge = Total number of activities that are overdue
        // userInfo : Probably need to include at least the activity uuid
        // attachments : Maybe include an icon
        
        let stats:ActivityStatistics = ActivityStatistics(activity: activity)
        content.title = activity.name ?? "Activity"
        content.subtitle = "Subtitle"
        content.body = "Next due date: " + stats.nextDay
        
        content.userInfo = ["UUID": uuid]
        
        // Set the category identifier
        content.categoryIdentifier = (activity.reminder?.allowSnooze)! ? DONE_AND_SNOOZE_CATEGORY_ID : DONE_ONLY_CATEGORY_ID
        // Set the thread identifier to the UUID of the Activity so they are grouped together
        content.threadIdentifier = uuid
        
        // Set up the trigger.
        // TODO: This should be a UNCalendarNotificationTrigger which is based off of the next notification date
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
        // Create the request
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        notificationCenter.add(request) {
            (error) in
            if error != nil {
                print("Unable to add notification request" + error!.localizedDescription)
            }
        }
    }
    
    func scheduleSnoozeReminder(for activity:ActivityMO) {
        let uuid = activity.id!.uuidString
        guard activity.reminder!.allowSnooze else {
            // If this activity is not enabled for snooze, then yank any pending notifications from
            // the notification center. User could have turned off snooze before the notification arrived.
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
            return
        }
        print("Scheduling snnoze for activity: \(activity.name ?? "") with uuid: \(uuid) ")
        let content = UNMutableNotificationContent()
        // TODO: Need to figure out the content to display
        // title = Activity Name
        // subtitle = Status of activity (ex: Activity is 10 days overdue or Activity is due tomorrow.
        // body = Longer description of the activity status (e.g. Last completed, Next due, Frequency, Avg interval, etc.
        // badge = Total number of activities that are overdue
        // userInfo : Probably need to include at least the activity uuid
        // attachments : Maybe include an icon
        
        let stats:ActivityStatistics = ActivityStatistics(activity: activity)
        content.title = activity.name ?? "Activity"
        content.subtitle = "You snooze, you lose."
        content.body = "Next due date: " + stats.nextDay
        
        content.userInfo = ["UUID": uuid]
        
        // Set the category identifier
        content.categoryIdentifier = (activity.reminder?.allowSnooze)! ? DONE_AND_SNOOZE_CATEGORY_ID : DONE_ONLY_CATEGORY_ID
        // Set the thread identifier to the UUID of the Activity so they are grouped together
        content.threadIdentifier = uuid
        
        // Set up the trigger.
        // TODO: This should be a UNCalendarNotificationTrigger which is based off of the next notification date
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
        // Create the request
        let request = UNNotificationRequest(identifier: uuid, content: content, trigger: trigger)
        
        notificationCenter.add(request) {
            (error) in
            if error != nil {
                print("Unable to add notification request" + error!.localizedDescription)
            }
        }

    }
    
    func removeAllPendingNotifications(for activity:ActivityMO) {
        let uuid = activity.id!.uuidString
        print("Cancelling reminder for activity: \(activity.name ?? "") with uuid: \(uuid) ")
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
    }
    
    
}

extension NotificationManager : UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        
        completionHandler([.alert, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        defer {
            completionHandler()
        }

        let request = response.notification.request
        let activityUUID = request.identifier
        guard let activity = dataManager.getActivityByID(uuid: activityUUID) else {
            return
        }
        
        switch (response.actionIdentifier) {
        case NotificationActions.MARK_DONE.rawValue:
            print("TODO: Mark done for \(request.identifier)")
            do {
                try dataManager.markActivityDone(activity: activity)
            } catch {
                // TODO: Alert the user?
            }
        case NotificationActions.SNOOZE.rawValue:
            print("TODO: Snooze for \(request.identifier)")
            scheduleSnoozeReminder(for: activity)
        case UNNotificationDefaultActionIdentifier:
            print("TODO: User pressed open")
        // TODO: We should navigate to the activity
        case UNNotificationDefaultActionIdentifier:
            print("TODO: User dismissed")
        default:
            print("TODO: Unknown action identifier")
        }
    }
    
}
