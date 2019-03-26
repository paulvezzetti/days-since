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
import UIKit

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
        
        DataModelManager.registerForAnyActivityChangeNotification(self, selector:  #selector(activityChanged(notification:)), activity: nil)
        
        checkApplicationBadge()

    }
    
    @objc func activityAdded(notification: Notification ) {
        guard let activity = notification.object as? ActivityMO else {
            return
        }
        scheduleReminderNotification(for: activity)
        checkApplicationBadge()
    }

    @objc func activityRemoved(notification: Notification ) {
        guard let activity = notification.object as? ActivityMO else {
            return
        }
        removeAllPendingNotifications(for: activity)
        checkApplicationBadge()
    }

    @objc func activityChanged(notification: Notification ) {
        guard let activity = notification.object as? ActivityMO else {
            return
        }
        removeAllPendingNotifications(for: activity)
        scheduleReminderNotification(for: activity)
        checkApplicationBadge()
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
        
        let stats = ActivityStatistics(activity: activity)
        guard let nextDate = stats.nextDate else { return }

        print("Scheduling reminder for activity: \(activity.name ?? "") with uuid: \(uuid) ")
        let content = buildContentForActivityNotification(activity)
        // Set up the trigger.
        let calendar = Calendar.current
        let daysBefore = activity.reminder?.daysBefore ?? 0
        
        let notificationDate = calendar.date(byAdding: .day, value: Int(-1 * daysBefore), to: nextDate)
        guard let triggerDate = notificationDate, triggerDate > Date() else { return }

        print("at: \(triggerDate.getFullString())")
        let dateComps = calendar.dateComponents(in: calendar.timeZone, from: triggerDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComps, repeats: false)
        //let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 15, repeats: false)
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
        guard activity.reminder!.allowSnooze && activity.reminder!.enabled else {
            // If this activity is not enabled for snooze, then yank any pending notifications from
            // the notification center. User could have turned off snooze before the notification arrived.
            notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
            return
        }
        print("Scheduling snnoze for activity: \(activity.name ?? "") with uuid: \(uuid) ")
        let content = buildContentForActivityNotification(activity)
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
    
    func buildContentForActivityNotification(_ activity:ActivityMO) -> UNMutableNotificationContent {
        let content = UNMutableNotificationContent()
        
        let stats:ActivityStatistics = ActivityStatistics(activity: activity)
        let nextDate = stats.nextDate
        let today = Date.normalize(date: Date())
        
        let activityName = activity.name ?? "An Activity"
        content.title = activityName
        if nextDate != nil {
            if nextDate! < today {
                content.subtitle = "Late: Due on " + nextDate!.getFullString()
            } else {
                content.subtitle = "Due on " + nextDate!.getFullString()
            }

        }
        let lastDate = stats.lastDate
        let daysSince = stats.daySince
        if lastDate != nil  && daysSince != nil {
            if daysSince! == 1 {
                content.body = "It has been " + String(stats.daySince!) + " day since it was last completed on " + stats.lastDate!.getFullString()

            } else {
                content.body = "It has been " + String(stats.daySince!) + " days since it was last completed on " + stats.lastDate!.getFullString()
            }
        }
        let uuid = activity.id!.uuidString
        content.userInfo = ["UUID": uuid]
        
        // Set the category identifier
        content.categoryIdentifier = (activity.reminder?.allowSnooze)! ? DONE_AND_SNOOZE_CATEGORY_ID : DONE_ONLY_CATEGORY_ID
        // Set the thread identifier to the UUID of the Activity so they are grouped together
        content.threadIdentifier = uuid

        return content
    }
    
    func removeAllPendingNotifications(for activity:ActivityMO) {
        let uuid = activity.id!.uuidString
        print("Cancelling reminder for activity: \(activity.name ?? "") with uuid: \(uuid) ")
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [uuid])
    }
    
    func checkApplicationBadge() {
        
        notificationCenter.getNotificationSettings { (settings) in
            guard settings.authorizationStatus == .authorized else { return }
            
            if settings.badgeSetting == .enabled {
                DispatchQueue.main.async {
                    self.updateApplicationBadgeCount()
                }
            }
        }
    }
    
    func updateApplicationBadgeCount() {
        do {
            let activities = try self.dataManager.getActivities()
            var overdueCount = 0
            for activity in activities {
                if activity.isOverdue {
                    overdueCount += 1
                }
            }
            UIApplication.shared.applicationIconBadgeNumber = overdueCount
        } catch {
            
        }
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
            do {
                try dataManager.markActivityDone(activity: activity)
            } catch {
                // TODO: Alert the user?
            }
        case NotificationActions.SNOOZE.rawValue:
            scheduleSnoozeReminder(for: activity)
        case UNNotificationDefaultActionIdentifier:
            NotificationCenter.default.post(name: Notification.Name.showActivity, object: activityUUID)
        default:
            print("TODO: Unknown action identifier")
        }
    }
    
}
