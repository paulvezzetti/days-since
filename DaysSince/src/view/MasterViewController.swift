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

    // MARK: - Public variables
    var detailViewController: DetailViewController? = nil
    var dataManager: DataModelManager? = nil {
        didSet {
            if isViewLoaded && dataManager != nil {
                onDataManagerAvailable()
            }
        }
    }
    
    // MARK: - Private variables
    private var activityDict: [ActivityMO.ActivityState : [ActivityMO] ] = [:]
    private var sectionIndices: [Int : ActivityMO.ActivityState] = [:]
    private var collapsedState: [ActivityMO.ActivityState : Bool] = [:]
    private var pendingActivityToShow: String? = nil

    // MARK: - Outlets
    @IBOutlet var navigationTitle: UINavigationItem!
    @IBOutlet weak var addButton: UIBarButtonItem!
    
    // MARK: Overrides
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
        
        if dataManager != nil {
            onDataManagerAvailable()
        }
        checkForEmptyListPrompt()
    }
    

    override func viewWillAppear(_ animated: Bool) {
        clearsSelectionOnViewWillAppear = splitViewController!.isCollapsed
        super.viewWillAppear(animated)
    }

    // MARK: - Observers
    @objc
    func managedObjectContextObjectsDidChange(notification: NSNotification) {
        buildTableDataStructure()
        tableView.reloadData()
    }
    
    @objc func onAnyActivityChanged(notification: Notification) {
        buildTableDataStructure()
        tableView.reloadData()        
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
    
    @IBAction func onMenuPress(_ sender: Any) {
        let alertAction = UIAlertController(title: "Export Data", message: "This action will export all of your data to a text file in the Documents directory on your device. You can use the Files app to share the file to other locations. Do you want to continue with the export?", preferredStyle: .alert)
        
        let exportAction = UIAlertAction(title: "Yes", style: .default) {(action:UIAlertAction!) in
            self.exportAllData()
        }
//        let importAction = UIAlertAction(title: "Import", style: .default, handler: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertAction.addAction(exportAction)
//        menu.addAction(importAction)
        alertAction.addAction(cancelAction)
        
        self.present(alertAction, animated: true, completion: nil)
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
        case .Pinned:
            headerView.statusImage.image = UIImage(named: "StarFilled")
        case .LastMonth, .LastWeek, .VeryOld, .Yesterday:
            headerView.statusImage.image = UIImage(named: "StatusIconLate")
        case .NextMonth, .NextWeek, .Tomorrow, .Future:
            headerView.statusImage.image = UIImage(named: "StatusIconOnTime")
        case ActivityMO.ActivityState.Today:
            headerView.statusImage.image = UIImage(named: "StatusIconToday")
        case .Whenever:
            headerView.statusImage.image = UIImage(named: "StatusIconUnlimited")
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
    
    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let pin = pinAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [pin])
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let state = sectionToStatus(section: indexPath.section)
        return collapsedState[state]! ? 0 : UITableView.automaticDimension
    }


}

// MARK: - Private extension

extension MasterViewController {
    
    private func onDataManagerAvailable() {
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
    
    private func buildTableDataStructure() {
        
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
    

    private func editAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("edit", value: "Edit", comment: "")) {[unowned self] (action, view, completion) in
            self.performSegue(withIdentifier: "presentAddActivity", sender: self.getActivity(at: indexPath))
            completion(true)
        }
        action.image = UIImage(named: "edit")
        action.backgroundColor = UIColor(named: "EditGray")
        return action
    }
    
    private func doneAction(at indexPath: IndexPath) -> UIContextualAction {
        
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
        action.backgroundColor = UIColor(named: "DoneGreen")
        return action
    }
    
    private func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("delete", value: "Delete", comment: "")) { (action, view, completion) in
            let alert = UIAlertController(title: NSLocalizedString("deleteActivity.title", value: "Delete this activity?", comment: "Title used for prompt when deleting activity"), message: NSLocalizedString("deleteActivity.msg", value: "This will permanently delete this activity and all of its history.", comment: "Message used for prompt when deleting activity"), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("delete", value: "Delete", comment: ""), style: .destructive) { (alert) in
                self.deleteActivity(at: indexPath)
            })
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", value: "Cancel", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            completion(true)
        }
        action.image = UIImage(named: "trash")
        action.backgroundColor = UIColor(named: "DeleteRed")
        return action
    }

    private func pinAction(at indexPath: IndexPath) -> UIContextualAction {
        guard let activity = self.getActivity(at: indexPath) else {
            return UIContextualAction(style: .normal, title: nil) {[] (action, view, completion) in
                completion(true)
            }
        }

        let title = activity.isPinned ? NSLocalizedString("remove", value: "Remove", comment: "") :NSLocalizedString("add", value: "Add", comment: "")
        let action = UIContextualAction(style: .normal, title: title) {[activity] (action, view, completion) in
            activity.isPinned = !activity.isPinned
            completion(true)
        }
        action.image = activity.isPinned ?  UIImage(named: "StarAlpha") : UIImage(named: "StarOutline")
        action.backgroundColor = activity.isPinned ? UIColor(named: "LapisBlue") : UIColor(named: "FavoriteBlue")
        return action
    }

    
    private func configureCell(_ cell: UITableViewCell, withActivity activity: ActivityMO) {
        guard let masterCell = cell as? MasterTableViewCell else {
            return
        }
        let stats:ActivityStatistics = ActivityStatistics(activity: activity)

        masterCell.nameLabel!.text = activity.name
        masterCell.nextLabel!.text = NSLocalizedString("next", value: "Next:", comment: "")
        masterCell.nextDateLabel!.text = stats.nextDay
        masterCell.lastLabel!.text = NSLocalizedString("last", value: "Last:", comment: "")
        masterCell.lastDateLabel!.text = stats.lastDay
        
        masterCell.progressView!.daysSince = stats.daySince
        masterCell.progressView!.daysUntil = stats.daysUntil
        
        masterCell.progressView!.setNeedsDisplay()
    }
    
    private func deleteActivity(at indexPath:IndexPath) {
        if let dm = dataManager, let activity = getActivity(at: indexPath) {
            do {
                try dm.removeActivity(activity: activity)
            } catch {
                let nserror = error as NSError
                let alert = UIAlertController(title: NSLocalizedString("deleteActivity.error.title", value: "Error deleting activity", comment: ""), message: NSLocalizedString("deleteActivity.error.msg", value: "An error occurred while attempting to delete the activity. If this continues, please kill the application and retry. The error was: \n\(nserror.localizedDescription)", comment: ""), preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: NSLocalizedString("ok", value: "OK", comment: ""), style: .default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    private func getActivity(at indexPath:IndexPath) -> ActivityMO? {
        let sectionActivities = activityDict[sectionToStatus(section: indexPath.section)] ?? []
        return sectionActivities.count > indexPath.row ? sectionActivities[indexPath.row] : nil
    }
    
    private func getIndexPathForActivity(activity:ActivityMO) -> IndexPath {
        return IndexPath(row: 0, section: 0)
    }
    
    private func sectionToStatus(section index:Int) -> ActivityMO.ActivityState {
        return sectionIndices[index] ?? ActivityMO.ActivityState.Whenever // TODO
    }
    
    private func checkForEmptyListPrompt() {
        if activityDict.count > 0 {
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            // Don't show popover if the count has changed or if the user navigated away from the master list
            if self.navigationController?.visibleViewController != self ||
                self.activityDict.count > 0 ||
                !self.splitViewController!.isCollapsed {
                return
            }
            let hintViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "startHintPopoverController") as! HintPopoverViewController
            hintViewController.modalPresentationStyle = .popover
            hintViewController.preferredContentSize = CGSize(width: 300.0, height: 75.0)
            
            if let popoverPresentationController = hintViewController.popoverPresentationController {
                popoverPresentationController.permittedArrowDirections = .up
                //popoverPresentationController.sourceView = self.navigationController!.navigationItem.rightBarButtonItem
                popoverPresentationController.barButtonItem = self.addButton
                popoverPresentationController.delegate = self
                self.present(hintViewController, animated: true, completion: nil)
            }
        }
    }
    
    private func exportAllData() {
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MMM-dd'T'HH-mm-ss"
//        formatter.dateStyle = .short
//        formatter.timeStyle = .short
//        let cal = Calendar.current
//        let dc = cal.dateComponents([.day, .month, .year, .hour, .minute, .second], from: date)
//        let formattedDate = "\(dc.day ?? 0)-\(dc.month ?? 0)-\(dc.year ?? 2000)at\(dc.hour ?? 12)-\(dc.minute ?? 0)-\(dc.second ?? 0)"
        let formattedDate = formatter.string(from: date)
//        formattedDate = formattedDate.replacingOccurrences(of: "/", with: "_")
//        formattedDate = formattedDate.replacingOccurrences(of: " ", with: "_")
//        formattedDate = formattedDate.replacingOccurrences(of: ":", with: "_")
        let fileName = "dayssince_\(formattedDate)"
        let DocumentDirURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        
        let fileURL = DocumentDirURL.appendingPathComponent(fileName).appendingPathExtension("dsj")
        print("FilePath: \(fileURL.path)")
        
        // Create the JSON String
        do {
            let allActivities = try dataManager?.getActivities()
            
            var codableActivities:[ActivityCodable] = []
            for activity in allActivities! {
                let codable = activity.asEncodable() as! ActivityCodable
                codableActivities.append(codable)
            }
            let baseModel = BaseModel(activities: codableActivities)
            
            let encoder = JSONEncoder()
//            encoder.outputFormatting = .prettyPrinted

            let data = try encoder.encode(baseModel)
            let jsonDataModel = String(data: data, encoding: .utf8)
            if let outputString = jsonDataModel {
                print(outputString)
                // Write to the file
                try outputString.write(to: fileURL, atomically: true, encoding: String.Encoding.utf8)
                
//                let decoder = JSONDecoder()
//                let result = try decoder.decode(BaseModel.self, from: outputString.data(using: .utf8)!)
//                if result.activities.count > 0 {
//                    print("Got \(result.activities.count) activities")
//                }
            }
        } catch let error as NSError {
            print("Failed writing to URL: \(fileURL), Error: " + error.localizedDescription)
        }
    }

}

// MARK: - MarkDoneDelegate
extension MasterViewController : MarkDoneDelegate {
    
    func complete(sender: UIViewController) {
        sender.navigationController!.popViewController(animated: false)
    }
    
}

// MARK: - CollapsibleTableViewHeaderDelegate
extension MasterViewController: CollapsibleTableViewHeaderDelegate {
    
    
    func toggleSection(header: ActivityTableHeaderView, section: Int) {
        let status = sectionToStatus(section: section)
        let collapsed = !collapsedState[status]!
        collapsedState[status] = collapsed
        
        header.setCollapsed(collapsed: collapsed)
        
        tableView.reloadSections([section], with: .automatic)
    }
    


}

extension MasterViewController : UIPopoverPresentationControllerDelegate {
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
    
}
