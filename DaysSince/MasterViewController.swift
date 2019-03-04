//
//  MasterViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/8/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController /*, NSFetchedResultsControllerDelegate */ {

    var detailViewController: DetailViewController? = nil
    //var managedObjectContext: NSManagedObjectContext? = nil
    var dataManager: DataModelManager? = nil
//    var activities: [ActivityMO] = []
    var activityDict: [ActivityMO.ActivityStatus : [ActivityMO] ] = [:]
    var sectionIndices: [Int : ActivityMO.ActivityStatus] = [:]


    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        navigationItem.leftBarButtonItem = editButtonItem

        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        
        rebuildDataStructures()

        do {
            
            let notificationCenter = NotificationCenter.default
            try notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: dataManager?.getManagedObjectContext())
        } catch {
            
        }
        //dataManager?.updateActivityStatus()
//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(showAddModally(_:)))
//        navigationItem.rightBarButtonItem = addButton
        if let split = splitViewController {
            let controllers = split.viewControllers
            detailViewController = (controllers[controllers.count-1] as! UINavigationController).topViewController as? DetailViewController
            detailViewController?.dataManager = dataManager
        }
        

    }

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
        
    }

    
    @objc
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
//        guard let userInfo = notification.userInfo else { return }
        // if there are any changes? update the table
        rebuildDataStructures()
        tableView.reloadData()
    }

    @objc
    func showAddModally(_ sender: Any) {
        // Safe Present
        if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AddTaskTable") as? AddActivityTableViewController
        {
            vc.dataManager = dataManager
            present(vc, animated: true, completion: nil)
        }
        
    }
    
    func rebuildDataStructures() {
        var overdue: [ActivityMO] = []
        var ontime: [ActivityMO] = []
        var soon: [ActivityMO] = []
        // Fetch the data
        if let dm = dataManager {
            do {
                let fetchedActivities = try dm.getActivities()
                for activity in fetchedActivities {
                    switch activity.status {
                    case ActivityMO.ActivityStatus.OverDue:
                        overdue.append(activity)
                    case ActivityMO.ActivityStatus.Soon:
                        soon.append(activity)
                    case ActivityMO.ActivityStatus.OnTime:
                        ontime.append(activity)
                    }
                }
                func sortByName(_ act1: ActivityMO, _ act2: ActivityMO) -> Bool {
                    return act1.name! < act2.name! // TODO: Handle nil for name better
                }
                overdue.sort(by: sortByName)
                ontime.sort(by: sortByName)
                soon.sort(by: sortByName)
                
                //                activities = try fetchedActivities.sorted{(act1: ActivityMO, _ act2: ActivityMO) throws -> Bool in
                //                    if (act1.status == act2.status) {
                //                        return act1.name! < act2.name!
                //                    }
                //                    return act1.status.rawValue < act2.status.rawValue
                //                }
                
            } catch {
                // TODO: Handle error
            }
        }
        activityDict.removeAll()
        var sectionIndex = 0
        sectionIndices.removeAll()
        if !overdue.isEmpty {
            activityDict[ActivityMO.ActivityStatus.OverDue] = overdue
            sectionIndices[sectionIndex] = ActivityMO.ActivityStatus.OverDue
            sectionIndex += 1
        }
        if !soon.isEmpty {
            activityDict[ActivityMO.ActivityStatus.Soon] = soon
            sectionIndices[sectionIndex] = ActivityMO.ActivityStatus.Soon
            sectionIndex += 1
        }
        if !ontime.isEmpty {
            activityDict[ActivityMO.ActivityStatus.OnTime] = ontime
            sectionIndices[sectionIndex] = ActivityMO.ActivityStatus.OnTime
            sectionIndex += 1
        }
        //        for a in activities {
        //            print ("Activity: \(a.name!) status: \(a.status)")
        //        }

    }
    
    func sectionToStatus(section index:Int) -> ActivityMO.ActivityStatus {
        return sectionIndices[index] ?? ActivityMO.ActivityStatus.OnTime // TODO
    }
    
//    @objc
//    func insertNewObject(_ sender: Any) {
//        let context = self.fetchedResultsController.managedObjectContext
//        let newEvent = EventMO(context: context)
//             
//        // If appropriate, configure the new managed object.
//        newEvent.timestamp = Date()
//
//        // Save the context.
//        do {
//            try context.save()
//        } catch {
//            // Replace this implementation with code to handle the error appropriately.
//            // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
//    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let sectionActivities = activityDict[sectionToStatus(section: indexPath.section)] ?? []
                let activity = sectionActivities[indexPath.row] // TODO: Array size check
//            let object = fetchedResultsController.object(at: indexPath)
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = activity //object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.dataManager = dataManager
            }
        }
        else if segue.identifier == "presentAddActivity" {
//            let controller = (segue.destination as! UINavigationController).topViewController as! AddActivityTableViewController
            let controller = segue.destination as! AddActivityTableViewController
            controller.dataManager = dataManager
        }
    }
    
    @IBAction func unwindSaveActivity(segue: UIStoryboardSegue) {
//        let controller = segue.source as! AddActivityTableViewController
//
//        controller.saveActivity()
//        controller.dismiss(animated: true, completion: nil)
        
        // TODO: Save the context
        do {
            try dataManager?.saveContext()
        } catch {
            
        }
    }


    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
       // return fetchedResultsController.sections?.count ?? 0
        return activityDict.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        let sectionInfo = fetchedResultsController.sections![section]
//        return sectionInfo.numberOfObjects
        
        // Get the section
        let activities = activityDict[sectionToStatus(section: section)] ?? []
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let status = sectionToStatus(section: section)
        switch status {
        case ActivityMO.ActivityStatus.OverDue:
            return "Over Due"
        case ActivityMO.ActivityStatus.OnTime:
            return "On Time"
        case ActivityMO.ActivityStatus.Soon:
            return "Soon"
        }
        
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "masterCell", for: indexPath) as! MasterTableViewCell
        let sectionActivities = activityDict[sectionToStatus(section: indexPath.section)] ?? []
        let activity = sectionActivities[indexPath.row] // TODO: Array size check

//        let event = fetchedResultsController.object(at: indexPath)
        configureCell(cell, withActivity: activity)
        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if let dm = dataManager {
                do {
                    let sectionActivities = activityDict[sectionToStatus(section: indexPath.section)] ?? []
                    let activity = sectionActivities[indexPath.row] // TODO: Array size check
                    try dm.removeActivity(activity: activity)
//                    try dm.removeActivity(activity: fetchedResultsController.object(at: indexPath))
                } catch {
                    // Replace this implementation with code to handle the error appropriately.
                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    // TODO: This should show an error screen.
                    let nserror = error as NSError
                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")

                }
            }
//            let context = fetchedResultsController.managedObjectContext
//            context.delete(fetchedResultsController.object(at: indexPath))
//
//            do {
//                try context.save()
//            } catch {
//                // Replace this implementation with code to handle the error appropriately.
//                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                let nserror = error as NSError
//                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//            }
        }
    }

    func configureCell(_ cell: UITableViewCell, withActivity activity: ActivityMO) {
        guard let masterCell = cell as? MasterTableViewCell else {
            return
        }
        let stats:ActivityStatistics = ActivityStatistics(activity: activity)
        masterCell.nameLabel!.text = activity.name
        masterCell.freqLabel!.text = String(stats.daySince)
        masterCell.nextDateLabel!.text = stats.nextDay
        masterCell.lastDateLabel!.text = stats.lastDay
        
        print("Activity: \(activity.name ?? "unknown") is overdue: \(activity.isOverdue)")
        
//        cell.textLabel!.text = activity.name
    }

    // MARK: - Fetched results controller

//    var fetchedResultsController: NSFetchedResultsController<ActivityMO> {
//        if _fetchedResultsController != nil {
//            return _fetchedResultsController!
//        }
//        guard let dm = dataManager else {
//            fatalError()
//        }
//        let fetchRequest: NSFetchRequest<ActivityMO> = ActivityMO.fetchRequest()
//
//        // Set the batch size to a suitable number.
//        fetchRequest.fetchBatchSize = 20
//
//        // Edit the sort key as appropriate.
//        //let sortStatusDescriptor = NSSortDescriptor(key: "status", ascending: false)
//        let sortDescriptor = NSSortDescriptor(key: "name", ascending: false)
//
//        fetchRequest.sortDescriptors = [/*sortStatusDescriptor,*/ sortDescriptor]
//
//        // Edit the section name key path and cache name if appropriate.
//        // nil for section name key path means "no sections".
//        do {
//            let moContext = try dm.getManagedObjectContext()
//
//            let aFetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: moContext, sectionNameKeyPath: nil, cacheName: "Master")
//            aFetchedResultsController.delegate = self
//            _fetchedResultsController = aFetchedResultsController
//
//            try _fetchedResultsController!.performFetch()
//        } catch {
//             // Replace this implementation with code to handle the error appropriately.
//             // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//             let nserror = error as NSError
//             fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
//
//        return _fetchedResultsController!
//    }
//    var _fetchedResultsController: NSFetchedResultsController<ActivityMO>? = nil
//
//    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.beginUpdates()
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
//        switch type {
//            case .insert:
//                tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
//            case .delete:
//                tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
//            default:
//                return
//        }
//    }
//
//    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
//        switch type {
//            case .insert:
//                tableView.insertRows(at: [newIndexPath!], with: .fade)
//            case .delete:
//                tableView.deleteRows(at: [indexPath!], with: .fade)
//            case .update:
//                configureCell(tableView.cellForRow(at: indexPath!)!, withActivity: anObject as! ActivityMO)
//            case .move:
//                configureCell(tableView.cellForRow(at: indexPath!)!, withActivity: anObject as! ActivityMO)
//                tableView.moveRow(at: indexPath!, to: newIndexPath!)
//        }
//    }
//
//    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
//        tableView.endUpdates()
//    }

    /*
     // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed.
     
     func controllerDidChangeContent(controller: NSFetchedResultsController) {
         // In the simplest, most efficient, case, reload the table view.
         tableView.reloadData()
     }
     */

}

