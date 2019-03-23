//
//  DataModelManager.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/11/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
import CoreData
import Foundation

class DataModelManager {
    
    private static let MIN_FREQ:Int = 0
    private static let MAX_FREQ:Int = 18262 // Roughly 50 years
    
    private var loadError: NSError?
    private var managedObjectContext: NSManagedObjectContext?
    
    private lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "DaysSince")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    
    func getManagedObjectContext() throws -> NSManagedObjectContext {
        if managedObjectContext != nil {
            return managedObjectContext!
        }
        let container = persistentContainer
        if loadError != nil {
            throw loadError!
        }
        managedObjectContext = container.viewContext
        
        // Add Observer
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
//        notificationCenter.addObserver(self, selector: #selector(managedObjectContextWillSave), name: NSManagedObjectContextWillSaveNotification, object: managedObjectContext)
//        notificationCenter.addObserver(self, selector: #selector(managedObjectContextDidSave), name: NSManagedObjectContextDidSaveNotification, object: managedObjectContext)

        
        
        return managedObjectContext!
    }
    
    @objc
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        guard let userInfo = notification.userInfo else { return }
        print("---> Managed Object Did Change")
        // Check for inserts. Any new object creation is an insert.
        
        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
            print("--- INSERTS count: \(inserts.count)")
            // When an activity is created, we get inserts for the activity and all of its components.
            // We only want to send a notification for the activity and not the subcomponents
            var newActivity:ActivityMO?
            var newEvent:EventMO?
            for mo in inserts {
                if let activity = mo as? ActivityMO {
                    print("INSERT activity \(activity.name!)")
                    newActivity = activity
                } else if let event = mo as? EventMO {
                    print("INSERT event \(event.timestamp!)")
                    newEvent = event
                }
                else if let interval = mo as? IntervalMO {
                    print("INSERT interval: " + interval.toPrettyString() + " for activity: \(interval.activity?.name ?? "nil")" )
                } else if let _ = mo as? ReminderMO {
                    print("INSERT reminder")
                }
            }
            
            if newActivity != nil {
                print("POST: ActivityAdded for activity: " + newActivity!.name!)
                NotificationCenter.default.post(name: Notification.Name.activityAdded, object: newActivity)
                return
            } else if newEvent != nil {
                print("POST: EventAdded for event: " + newEvent!.getFormattedDate(style: .full))
                NotificationCenter.default.post(name: Notification.Name.eventAdded, object: newEvent?.activity)
                return
            }
            print("--- End INSERTS")
        }
        
        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
            print("--- DELETES count :\(deletes.count)")
            //            print(deletes)
            //            print("+++++++++++++++")
            // We only care about deleted activities or events
            var deletedActivity:ActivityMO?
            var deletedEvent:EventMO?
            for mo in deletes {
                if let activity = mo as? ActivityMO {
                    print("DELETE activity \(activity.name!)")
                    deletedActivity = activity
                } else if let event = mo as? EventMO {
                    print("DELETE event \(event.timestamp!)")
                    deletedEvent = event
                }
                else if let interval = mo as? IntervalMO {
                    print("DELETE for interval: " + interval.toPrettyString() + " for activity: \(interval.activity?.name ?? "nil")")
                } else if let _ = mo as? ReminderMO {
                    print("DELETE for reminder")
                }
            }
            if deletedActivity != nil {
                print("POST: ActivityRemoved for activity: " + deletedActivity!.name!)
                NotificationCenter.default.post(name: Notification.Name.activityRemoved, object: deletedActivity)
                return
            } else if deletedEvent != nil {
                print("POST: EventRemoved for event: " + deletedEvent!.getFormattedDate(style: .full))
                // If an event was removed, it's reference to the activity is null. However, we should be able to
                // get it from the updates.
                if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
                    for update in updates {
                        if let activity = update as? ActivityMO {
                            deletedActivity = activity
                            break
                        }
                    }
                }
                NotificationCenter.default.post(name: Notification.Name.eventRemoved, object: deletedActivity)
                return
            }

            print("--- End DELETES")
        }

        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
            print("--- UPDATES count: \(updates.count)")
            for update in updates {
                print("**** Changed values for current event ****")
                let currentValues = update.changedValuesForCurrentEvent()
                if currentValues.count == 0 {
                    print("No changed values")
                    continue
                }
                print(currentValues)
                print("******************************************")
                if let activity = update as? ActivityMO {
                    print("POST activityChanged for activity \(activity.name!)")
                    NotificationCenter.default.post(name: Notification.Name.activityChanged, object: activity)
                } else if let event = update as? EventMO {
                    print("POST eventChanged at \(event.getFormattedDate(style: .long))")
                    NotificationCenter.default.post(name: Notification.Name.eventChanged, object: event)
                }
                else if let interval = update as? IntervalMO {
                    print("Update for interval : " + interval.toPrettyString())
                } else if let reminder = update as? ReminderMO {
                    print("POST for reminder")
                    NotificationCenter.default.post(name: Notification.Name.reminderChanged, object: reminder.activity)
                }

            }
            print("--- End UPDATES")
        }
        
        print("<--- Managed Object Did Change")

    }
    
    
    func getActivities() throws -> [ActivityMO]{
        let context = try getManagedObjectContext()
        let fetch = NSFetchRequest<ActivityMO>(entityName: "Activity")
        return try context.fetch(fetch)
    }
    
    func getActivityByID(uuid:String) -> ActivityMO? {
        do {
            let activities = try getActivities()
            for activity in activities {
                if activity.id?.uuidString == uuid {
                    return activity
                }
            }
        } catch {
            
        }
        return nil
    }
    
    
    func newChildManagedObjectContext() throws -> NSManagedObjectContext {
        let childMOC = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        childMOC.parent = try getManagedObjectContext()
        return childMOC
    }
    
    func removeActivity(activity: ActivityMO) throws {
        let context = try getManagedObjectContext()
        context.delete(activity)
        try save(context)
    }
    
    func markActivityDone(activity:ActivityMO, at date:Date? = nil, with details:String? = nil) throws {
        let context = try getManagedObjectContext()
        let event = EventMO(context: context)
        event.timestamp = Date.normalize(date: date ?? Date())
        if details != nil {
            event.details = details
        }
        activity.addToHistory(event)
        
        try save(context)
    }
    
    func removeEvent(activity:ActivityMO, event:EventMO) throws {
        activity.removeFromHistory(event)
        let context = try getManagedObjectContext()
        context.delete(event)
        try save(context)
    }
    
    
    func saveContext() throws {
        let context = try getManagedObjectContext()
        try save(context)
    }
    
    private func save(_ context: NSManagedObjectContext) throws {
        if context.hasChanges {
           try context.save()
        }
    }

    
    static func registerForAnyActivityChangeNotification(_ observer:Any, selector: Selector, activity:ActivityMO?) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name.activityChanged, object: activity)
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name.intervalChanged, object: activity)
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name.eventAdded, object: activity)
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name.eventChanged, object: activity)
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name.eventRemoved, object: activity)
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name.reminderChanged, object: activity)

    }
    
    static func registerForActivityListChangeNotification(_ observer:Any, selector: Selector) {
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name.activityAdded, object: nil)
        NotificationCenter.default.addObserver(observer, selector: selector, name: NSNotification.Name.activityRemoved, object: nil)
    }
    static func registerForNamedNotifications(_ observer:Any, selector: Selector, names: [NSNotification.Name], object: Any?) {
        for name in names {
            NotificationCenter.default.addObserver(observer, selector: selector, name: name, object: object)
        }
    }
}

extension Notification.Name {
    
    static let activityAdded = Notification.Name("activityAdded")
    static let activityRemoved = Notification.Name("activityRemoved")
    static let activityChanged = Notification.Name("activityChanged")
    static let intervalChanged = Notification.Name("intervalChanged")
    static let eventAdded = Notification.Name("eventAdded")
    static let eventChanged = Notification.Name("eventChanged")
    static let eventRemoved = Notification.Name("eventRemoved")
    static let reminderChanged = Notification.Name("reminderChanged")
    
}
