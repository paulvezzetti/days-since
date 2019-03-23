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
    var activityDict: [ActivityMO.ActivityState : [ActivityMO] ] = [:]
    var sectionIndices: [Int : ActivityMO.ActivityState] = [:]
    var collapsedState: [ActivityMO.ActivityState : Bool] = [:] 

    //private var markDoneIndexPath:IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        self.clearsSelectionOnViewWillAppear = false
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 140
        
        let headerNib = UINib.init(nibName: "ActivityTableHeaderView", bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "ActivityTableHeaderView")
        
        
        for possibleState in ActivityMO.ActivityState.allCases {
            collapsedState[possibleState] = false
        }

        //rebuildDataStructures()
        buildTableDataStructure()

        // Remove any current observers
        NotificationCenter.default.removeObserver(self)
        // Add new observers
        DataModelManager.registerForAnyActivityChangeNotification(self, selector: #selector(onAnyActivityChanged(notification:)), activity: nil)
        DataModelManager.registerForActivityListChangeNotification(self, selector: #selector(onAnyActivityChanged(notification:)))

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
        buildTableDataStructure()
//        rebuildDataStructures()
        tableView.reloadData()
    }
    
    @objc func onAnyActivityChanged(notification: Notification) {
        buildTableDataStructure()
//        rebuildDataStructures()
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
    
    func buildTableDataStructure() {
        
        var activityMap: [ActivityMO.ActivityState : [ActivityMO] ] = [:]
        
        func addToMap(state:ActivityMO.ActivityState, activity:ActivityMO) {
            if var activityValues = activityMap[state] {
                // Array of activities already exists, just add to it.
                activityValues.append(activity)
            } else {
                // Create a new array
                let activityValues = [activity]
                activityMap[state] = activityValues
            }
        }
        
        if let dm = dataManager {
            do {
                let fetchedActivities = try dm.getActivities()
                for activity in fetchedActivities {
                    addToMap(state: activity.state, activity: activity)
                }
            } catch {
                // TODO: Handle error
            }
        }
        // Sort all of the arrays in the map
        func sortByName(_ act1: ActivityMO, _ act2: ActivityMO) -> Bool {
            return act1.name! < act2.name! // TODO: Handle nil for name better
        }
        for (state, activityValues) in activityMap {
            let sortedActivities = activityValues.sorted(by: sortByName)
            activityMap[state] = sortedActivities
        }
        self.activityDict = activityMap
        // Get the section indices
        var sectionIndex = 0
        for possibleState in ActivityMO.ActivityState.allCases {
            if let _ = activityMap[possibleState] {
                sectionIndices[sectionIndex] = possibleState
                sectionIndex += 1
            }
        }
    }
    
    
    func sectionToStatus(section index:Int) -> ActivityMO.ActivityState {
        return sectionIndices[index] ?? ActivityMO.ActivityState.Whenever // TODO
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
            if let activity = sender as? ActivityMO {
                controller.editActivity = activity
            }
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
        let state = sectionToStatus(section: section)
        if collapsedState[state]! {
            return 0
        }
        let activities = activityDict[state] ?? []
        return activities.count
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ActivityTableHeaderView") as! ActivityTableHeaderView
        
        headerView.section = section
        headerView.delegate = self
        
        let greenView = UIView(frame: headerView.frame)
        greenView.backgroundColor = UIColor(named:"Medium Green")
        headerView.backgroundView = greenView
        
        let redView = UIView(frame: headerView.frame)
        redView.backgroundColor = UIColor(named: "Alert Red")
        
        let state = sectionToStatus(section: section)
        switch state {
        case ActivityMO.ActivityState.Future:
            headerView.headerTitleLabel.text = "Distant Future"
        case ActivityMO.ActivityState.LastMonth:
            headerView.headerTitleLabel.text = "Overdue - Last Month"
            headerView.backgroundView = redView
        case ActivityMO.ActivityState.LastWeek:
            headerView.headerTitleLabel.text = "Overdue - Last Week"
            headerView.backgroundView = redView
        case ActivityMO.ActivityState.NextMonth:
            headerView.headerTitleLabel.text = "Next Month"
        case ActivityMO.ActivityState.NextWeek:
            headerView.headerTitleLabel.text = "Next Week"
        case ActivityMO.ActivityState.Today:
            headerView.headerTitleLabel.text = "Today"
        case ActivityMO.ActivityState.Tomorrow:
            headerView.headerTitleLabel.text = "Tomorrow"
        case ActivityMO.ActivityState.VeryOld:
            headerView.headerTitleLabel.text = "Overdue - More than a month"
            headerView.backgroundView = redView
        case ActivityMO.ActivityState.Whenever:
            headerView.headerTitleLabel.text = "No due date"
        case ActivityMO.ActivityState.Yesterday:
            headerView.headerTitleLabel.text = "Overdue - Yesterday"
            headerView.backgroundView = redView
        }

        headerView.setCollapsed(collapsed: collapsedState[state]!)
        
        return headerView
    }
    
//    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
//        guard let headerView = view as? ActivityTableHeaderView else {
//            return
//        }
//        let greenView = UIView(frame: headerView.frame)
//        greenView.backgroundColor = UIColor.green
//
//        let state = sectionToStatus(section: section)
//        switch state {
//        case ActivityMO.ActivityState.Future:
//            headerView.subView.backgroundColor = UIColor(named: "green")
//        case ActivityMO.ActivityState.LastMonth:
//            headerView.subView.backgroundColor = UIColor(named: "red")
//        case ActivityMO.ActivityState.LastWeek:
//            headerView.subView.backgroundColor = UIColor(named: "red")
//        case ActivityMO.ActivityState.NextMonth:
//            headerView.subView.backgroundColor = UIColor(named: "green")
//        case ActivityMO.ActivityState.NextWeek:
//            headerView.subView.backgroundColor = UIColor(named: "green")
//        case ActivityMO.ActivityState.Today:
//            headerView.subView.backgroundColor = UIColor(named: "green")
//        case ActivityMO.ActivityState.Tomorrow:
//            //headerView.subView.backgroundColor = UIColor(named: "green")
//            //headerView.backgroundColor = UIColor(named: "green")
//            headerView.backgroundView = greenView
//        case ActivityMO.ActivityState.VeryOld:
//            headerView.subView.backgroundColor = UIColor(named: "red")
//        case ActivityMO.ActivityState.Whenever:
//            headerView.subView.backgroundColor = UIColor(named: "green")
//        case ActivityMO.ActivityState.Yesterday:
//            headerView.subView.backgroundColor = UIColor(named: "red")
//        }
//
//    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    
//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        let state = sectionToStatus(section: section)
//        switch state {
//        case ActivityMO.ActivityState.Future:
//            return "Distant Future"
//        case ActivityMO.ActivityState.LastMonth:
//            return "Overdue - Last Month"
//        case ActivityMO.ActivityState.LastWeek:
//            return "Overdue - Last Week"
//        case ActivityMO.ActivityState.NextMonth:
//            return "Next Month"
//        case ActivityMO.ActivityState.NextWeek:
//            return "Next Week"
//        case ActivityMO.ActivityState.Today:
//            return "Today"
//        case ActivityMO.ActivityState.Tomorrow:
//            return "Tomorrow"
//        case ActivityMO.ActivityState.VeryOld:
//            return "Overdue - More than a month"
//        case ActivityMO.ActivityState.Whenever:
//            return "No due date"
//        case ActivityMO.ActivityState.Yesterday:
//            return "Overdue - Yesterday"
//        }
//
//    }

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
        let edit = editAction(at: indexPath)
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [edit, delete, done])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let state = sectionToStatus(section: indexPath.section)
        return collapsedState[state]! ? 0 : UITableView.automaticDimension
    }

    func editAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Edit") {[unowned self] (action, view, completion) in
            self.performSegue(withIdentifier: "presentAddActivity", sender: self.getActivity(at: indexPath))
            completion(true)
        }
        action.image = UIImage(named: "edit")
        //action.backgroundColor = UIColor(named: "Medium Green")
        return action
    }

    func doneAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: "Done") {[unowned self] (action, view, completion) in
            if let vc = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "markDoneNavigationController") as? MarkDoneTableViewController
            {
                vc.doneDelegate = self
                vc.activity = self.getActivity(at: indexPath)
                vc.dataManager = self.dataManager
                self.show(vc, sender: self)
            }
            completion(true)
        }
        action.image = UIImage(named: "done")
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
        action.backgroundColor = .red
        return action
    }


    func configureCell(_ cell: UITableViewCell, withActivity activity: ActivityMO) {
        guard let masterCell = cell as? MasterTableViewCell else {
            return
        }
        let stats:ActivityStatistics = ActivityStatistics(activity: activity)
        let daysSince = stats.daySince
        masterCell.nameLabel!.text = activity.name
        masterCell.freqLabel!.text = daysSince != nil ? String(stats.daySince!) : "--"
        masterCell.nextDateLabel!.text = stats.nextDay
        masterCell.lastDateLabel!.text = stats.lastDay
    }
    
    func deleteActivity(at indexPath:IndexPath) {
        if let dm = dataManager {
            do {
                let activity = getActivity(at: indexPath)
                try dm.removeActivity(activity: activity)
            } catch {
                // TODO: This should show an error screen.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func getActivity(at indexPath:IndexPath) -> ActivityMO {
        let sectionActivities = activityDict[sectionToStatus(section: indexPath.section)] ?? []
        return sectionActivities[indexPath.row] // TODO: Array size check
    }

}

extension MasterViewController : MarkDoneDelegate {
    
    func complete(sender: UIViewController) {
        sender.navigationController!.popViewController(animated: false)
    }
    
}

extension MasterViewController: CollapsibleTableViewHeaderDelegate {
    
    
    func toggleSection(header: ActivityTableHeaderView, section: Int) {
        let status = sectionToStatus(section: section)
        let collapsed = !collapsedState[status]!
        collapsedState[status] = collapsed
        
        header.setCollapsed(collapsed: collapsed)
        
        tableView.reloadSections([section], with: .automatic)
    }
    


}
