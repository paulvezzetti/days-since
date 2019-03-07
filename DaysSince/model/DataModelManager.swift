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
//        let notificationCenter = NotificationCenter.default
//        notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
//        notificationCenter.addObserver(self, selector: #selector(managedObjectContextWillSave), name: NSManagedObjectContextWillSaveNotification, object: managedObjectContext)
//        notificationCenter.addObserver(self, selector: #selector(managedObjectContextDidSave), name: NSManagedObjectContextDidSaveNotification, object: managedObjectContext)

        
        
        return managedObjectContext!
    }
//    
//    @objc
//    func managedObjectContextObjectsDidChange(notification: NSNotification) {
//        guard let userInfo = notification.userInfo else { return }
//        
//        if let inserts = userInfo[NSInsertedObjectsKey] as? Set<NSManagedObject>, inserts.count > 0 {
//            print("--- INSERTS ---")
//            print(inserts)
//            print("+++++++++++++++")
//            for mo in inserts {
//                if let activity = mo as? ActivityMO {
//                    print("Inserted activity \(activity.name!)")
//                } else if let event = mo as? EventMO {
//                    print("Inserted event \(event.timestamp!)")
//                }
//            }
//        }
//        
//        if let updates = userInfo[NSUpdatedObjectsKey] as? Set<NSManagedObject>, updates.count > 0 {
//            print("--- UPDATES ---")
//            for update in updates {
//                print(update.changedValues())
//            }
//            print("+++++++++++++++")
//        }
//        
//        if let deletes = userInfo[NSDeletedObjectsKey] as? Set<NSManagedObject>, deletes.count > 0 {
//            print("--- DELETES ---")
//            print(deletes)
//            print("+++++++++++++++")
//        }
//    }
    
//    func updateActivityStatus() {
//        do {
//            let context = try getManagedObjectContext()
//            let activityFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Activity")
//            
//            let activities = try context.fetch(activityFetch) as! [ActivityMO]
//            
//            for activity in activities {
//                if activity.isOverdue {
//                    activity.status = "Overdue"
//                } else {
//                    activity.status = "On-time"
//                }
//                context.refresh(activity, mergeChanges: true)
//            }
//        } catch {
//            
//        }
//        
//        
//    }
    
    func getActivities() throws -> [ActivityMO]{
        let context = try getManagedObjectContext()
        let fetch = NSFetchRequest<ActivityMO>(entityName: "Activity")
        return try context.fetch(fetch)
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
    
    func setEventDone(activity:ActivityMO, at date:Date) throws {
        let context = try getManagedObjectContext()
        let event = EventMO(context: context)
        event.timestamp = date
        
        activity.addToHistory(event)
      //  try save(context)
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

}
