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
    var pendingActivityToShow: String? = nil

    @IBOutlet var navigationTitle: UINavigationItem!
    
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

        buildTableDataStructure()

        // Remove any current observers
        NotificationCenter.default.removeObserver(self)
        // Add new observers
        DataModelManager.registerForAnyActivityChangeNotification(self, selector: #selector(onAnyActivityChanged(notification:)), activity: nil)
        DataModelManager.registerForActivityListChangeNotification(self, selector: #selector(onAnyActivityChanged(notification:)))
        
        NotificationCenter.default.addObserver(self, selector: #selector(showActivityRequest(notification:)), name: Notification.Name.showActivity, object: nil)

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
        tableView.reloadData()
    }
    
    @objc func onAnyActivityChanged(notification: Notification) {
        buildTableDataStructure()
        tableView.reloadData()
        
        if notification.name == Notification.Name.activityAdded {
            if let activity = notification.object as? ActivityMO {
                if self.isViewLoaded {
                    self.performSegue(withIdentifier: "showDetail", sender: activity)
                }
            }
        }
    }
    
    @objc func showActivityRequest(notification:Notification) {
        pendingActivityToShow = notification.object as? String
        if self.isViewLoaded {
            self.performSegue(withIdentifier: "showDetail", sender: self)
        }
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
                activityMap[state] = activityValues
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
            var activity: ActivityMO? = nil
            if sender is ActivityMO {
                activity = sender as? ActivityMO
            } else if pendingActivityToShow != nil {
                activity = self.dataManager?.getActivityByID(uuid: pendingActivityToShow!)
                pendingActivityToShow = nil
            }
            else if let indexPath = tableView.indexPathForSelectedRow {
                let sectionActivities = activityDict[sectionToStatus(section: indexPath.section)] ?? []
                activity = sectionActivities[indexPath.row] // TODO: Array size check
            }
            if activity != nil {
                let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController
                controller.detailItem = activity //object
                controller.navigationItem.leftBarButtonItem = splitViewController?.displayModeButtonItem
                controller.navigationItem.leftItemsSupplementBackButton = true
                controller.dataManager = dataManager
            }
        }
        else if segue.identifier == "presentAddActivity" {
            let controller = segue.destination as! AddActivityTableViewController
            controller.dataManager = dataManager
            if let activity = sender as? ActivityMO {
                controller.editActivity = activity
            }
        }
    }
    
    @IBAction func unwindSaveActivity(segue: UIStoryboardSegue) {
//        do {
//            try dataManager?.saveContext()
//        } catch {
//            let nserror = error as NSError
//            fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
//        }
    }


    // MARK: - Table View

    override func numberOfSections(in tableView: UITableView) -> Int {
       // return fetchedResultsController.sections?.count ?? 0
        return activityDict.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
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
        greenView.backgroundColor = UIColor(named:"Header")
        headerView.backgroundView = greenView
        
        let state = sectionToStatus(section: section)
        headerView.headerTitleLabel.text = state.asString()
        
        switch state {
        case .LastMonth, .LastWeek, .VeryOld, .Yesterday:
            headerView.statusImage.image = UIImage(named: "LateIcon")
        case .NextMonth, .NextWeek, .Tomorrow, .Future:
            headerView.statusImage.image = UIImage(named: "CompleteIcon")
        case ActivityMO.ActivityState.Today:
            headerView.statusImage.image = UIImage(named: "TodayIcon")
        case .Whenever:
            headerView.statusImage.image = UIImage(named: "UnlimitedStatusIcon")
        }

        headerView.setCollapsed(collapsed: collapsedState[state]!)
        
        return headerView
    }
    
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35
    }
    

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "masterCell", for: indexPath) as! MasterTableViewCell
        let sectionActivities = activityDict[sectionToStatus(section: indexPath.section)] ?? []
        let activity = sectionActivities[indexPath.row] // TODO: Array size check

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
        
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("edit", value: "Edit", comment: "")) {[unowned self] (action, view, completion) in
            self.performSegue(withIdentifier: "presentAddActivity", sender: self.getActivity(at: indexPath))
            completion(true)
        }
        action.image = UIImage(named: "edit")
        return action
    }

    func doneAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("done", value: "Done", comment: "")) {[unowned self] (action, view, completion) in
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
        
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("delete", value: "Delete", comment: "")) { (action, view, completion) in
            let alert = UIAlertController(title: NSLocalizedString("deleteActivity.title", value: "Delete this activity?", comment: "Title used for prompt when deleting activity") ,
                                          message: NSLocalizedString("deleteActivity.msg", value: "This will permanently delete this activity and all of its history.", comment: "Message used for prompt when deleting activity"), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("yes", value: "Yes", comment: ""), style: .destructive) { (alert) in
                self.deleteActivity(at: indexPath)
            })
            alert.addAction(UIAlertAction(title: NSLocalizedString("no", value: "No", comment: ""), style: .default, handler: nil))
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
        //let daysSince = stats.daySince
        masterCell.nameLabel!.text = activity.name
        masterCell.nextLabel!.text = NSLocalizedString("next", value: "Next:", comment: "")
        masterCell.nextDateLabel!.text = stats.nextDay
        masterCell.lastLabel!.text = NSLocalizedString("last", value: "Last:", comment: "")
        masterCell.lastDateLabel!.text = stats.lastDay
        
        masterCell.progressView!.daysSince = stats.daySince
        masterCell.progressView!.daysUntil = stats.daysUntil
        
        masterCell.progressView!.setNeedsDisplay()
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
    
    func getIndexPathForActivity(activity:ActivityMO) -> IndexPath {
        
        return IndexPath(row: 0, section: 0)
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
