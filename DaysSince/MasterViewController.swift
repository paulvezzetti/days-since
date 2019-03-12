//
//  MasterViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/8/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit
import CoreData

class MasterViewController: UITableViewController {

    var detailViewController: DetailViewController? = nil
    var dataManager: DataModelManager? = nil
    var activityDict: [ActivityMO.ActivityStatus : [ActivityMO] ] = [:]
    var sectionIndices: [Int : ActivityMO.ActivityStatus] = [:]

    private var markDoneIndexPath:IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.clearsSelectionOnViewWillAppear = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        
        rebuildDataStructures()

        do {
            
            let notificationCenter = NotificationCenter.default
            try notificationCenter.addObserver(self, selector: #selector(managedObjectContextObjectsDidChange), name: NSNotification.Name.NSManagedObjectContextObjectsDidChange, object: dataManager?.getManagedObjectContext())
        } catch {
            
        }
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
    }
    
    func sectionToStatus(section index:Int) -> ActivityMO.ActivityStatus {
        return sectionIndices[index] ?? ActivityMO.ActivityStatus.OnTime // TODO
    }
    

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showDetail" {
            if let indexPath = tableView.indexPathForSelectedRow {
                let sectionActivities = activityDict[sectionToStatus(section: indexPath.section)] ?? []
                let activity = sectionActivities[indexPath.row] // TODO: Array size check
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
            let nserror = error as NSError
            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
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

    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let done = doneAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete, done])
    }
    
    func doneAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Done") { (action, view, completion) in
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "markDoneNavigationController") as? MarkDoneTableViewController
            {
                self.markDoneIndexPath = indexPath
                vc.doneDelegate = self
                self.show(vc, sender: self)
            }
            completion(true)
        }
        action.image = UIImage(named: "done")
        //action.title = "Mark Done"
        action.backgroundColor = UIColor(named: "Medium Green")
        return action
    }

    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            let alert = UIAlertController(title: "Delete this activity?", message: "This will permanently delete this activity and all of its history.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { (alert) in
                self.deleteActivity(at: indexPath)
            })
            alert.addAction(UIAlertAction(title: "No", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            completion(true)
        }
        action.image = UIImage(named: "trash")
        //action.title = "Delete"
        action.backgroundColor = .red
        return action
    }

//    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        // Return false if you do not want the specified item to be editable.
//        return true
//    }

//    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
//        if editingStyle == .delete {
//            if let dm = dataManager {
//                do {
//                    let sectionActivities = activityDict[sectionToStatus(section: indexPath.section)] ?? []
//                    let activity = sectionActivities[indexPath.row] // TODO: Array size check
//                    try dm.removeActivity(activity: activity)
//                } catch {
//                    // Replace this implementation with code to handle the error appropriately.
//                    // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                    // TODO: This should show an error screen.
//                    let nserror = error as NSError
//                    fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//
//                }
//            }
//        }
//    }

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
    
    func deleteActivity(at indexPath:IndexPath) {
        if let dm = dataManager {
            do {
                let sectionActivities = activityDict[sectionToStatus(section: indexPath.section)] ?? []
                let activity = sectionActivities[indexPath.row] // TODO: Array size check
                try dm.removeActivity(activity: activity)
            } catch {
                // TODO: This should show an error screen.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")

            }
        }
    }

}

extension MasterViewController : MarkDoneDelegate {
    func done(at date: Date, withDetails details: String, sender: UIViewController) {
        do {
            defer {
                sender.navigationController!.popViewController(animated: false)
            }
            
            guard let selectedIndex = markDoneIndexPath, let dm = dataManager else {
                return
            }
            let sectionActivities = activityDict[sectionToStatus(section: selectedIndex.section)] ?? []
            let activity = sectionActivities[selectedIndex.row] // TODO: Array size check
            let moc = try dm.getManagedObjectContext()
            let event = EventMO(context: moc)
            event.timestamp = Date.normalize(date: date)
            event.details = details
            activity.addToHistory(event)
            
            tableView.reloadRows(at: [selectedIndex], with: .automatic)
            
        } catch {
            
        }
    }
    
    func cancelled(sender: UIViewController) {
       // sender.dismiss(animated: false, completion: nil)
        sender.navigationController!.popViewController(animated: false)
    }
    
    
    
}


