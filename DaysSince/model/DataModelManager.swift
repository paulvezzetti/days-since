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
        return managedObjectContext!
    }
    
    func newActivity(named name:String) throws -> ActivityMO {
        let context = try getManagedObjectContext()
        let activity = ActivityMO(context: context)
        activity.id = UUID()
        activity.name = name
        return activity
    }
    
    func removeActivity(activity: ActivityMO) throws {
        let context = try getManagedObjectContext()
        context.delete(activity)
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

}
