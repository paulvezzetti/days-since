//
//  ImportTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/14/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ImportTableViewController: UITableViewController {

    
    var baseModel:BaseModel? = nil {
        didSet {
            if isViewLoaded {
                
            }
        }
    }
    var dataManager: DataModelManager? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleImportAppendActivities(notification:)), name: Notification.Name(ImportHeaderView.IMPORT_APPEND_NOTIFICATION), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleImportReplaceActivities(notification:)), name: Notification.Name(ImportHeaderView.IMPORT_REPLACE_NOTIFICATION), object: nil)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let headerNib = UINib.init(nibName: "ImportHeaderView", bundle: nil)
        tableView.register(headerNib, forHeaderFooterViewReuseIdentifier: "ImportHeaderView")

    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let model = baseModel else {
            return 0
        }
        return model.activities.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "importCell", for: indexPath) as! ImportTableViewCell

        guard let model = baseModel, model.activities.count > indexPath.row else {
            return cell
        }
        let activity = baseModel?.activities[indexPath.row]
        cell.titleLabel.text = activity?.name
        cell.intervalLabel.text = "Interval"
        cell.historyLabel.text = String(activity?.events.count ?? 0)
        return cell
    }
    
//    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return UITableViewCell.EditingStyle.none
//    }


    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    

    
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            if let model = baseModel, model.activities.count > indexPath.row {
                model.activities.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
            print("Insert")
        }
    }
    
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: "ImportHeaderView") as! ImportHeaderView
        
        let backColorView = UIView(frame: headerView.frame)
        backColorView.backgroundColor = UIColor(named:"Header")
        headerView.backgroundView = backColorView

        
        return headerView
    }
    

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */


    
    @objc
    func handleImportAppendActivities(notification: Notification) {
        print("Ready to append")
        insertImportedActivities(useSavedUUID: false)
    }

    @objc
    func handleImportReplaceActivities(notification: Notification) {
        print("Ready to import")
        guard let dm = dataManager else {
            return
        }
        do {
            try dm.removeAllActivities()
        } catch let error as NSError {
            print("Unable to delete all existing activities: \(error)")

        }
            
        insertImportedActivities(useSavedUUID: true)
    }
    
    func insertImportedActivities(useSavedUUID:Bool) {
        guard let dm = dataManager, let model = baseModel else {
            return
        }
        do {
            let childMOC = try dm.newChildManagedObjectContext()
            for activity in model.activities {
                let activityMO = ActivityMO(context: childMOC)
                activityMO.name = activity.name
                activityMO.isPinned = activity.isPinned
                activityMO.id = useSavedUUID ? UUID(uuidString: activity.uuid) : UUID()
                activityMO.interval = activity.interval.toIntervalMO(moc: childMOC)
                activityMO.reminder = activity.reminder.toReminderMO(moc: childMOC)
                for event in activity.events {
                    let eventMO = event.toEventMO(moc: childMOC)
                    if eventMO != nil {
                        activityMO.addToHistory(eventMO!)
                    }
                }
            }
            try childMOC.save()
            try dm.saveContext()
            
            let completeAlert = UIAlertController(title: "Import Complete", message: "Successfully imported \(model.activities.count) activities.", preferredStyle: .alert)
            completeAlert.addAction(UIAlertAction(title: NSLocalizedString("ok", value: "OK", comment: ""), style: .default, handler: onImportComplete))
            self.present(completeAlert, animated: true, completion: nil)
        } catch let error as NSError {
            print("Unable to save activities: \(error)")
            let alert = UIAlertController(title: "Error importing data", message: "An error occurred importing your data. The file may be in an invalid format. \n\(error)", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("ok", value: "OK", comment: ""), style: .default, handler: onImportComplete))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func onImportComplete(action: UIAlertAction!) {
        self.navigationController?.popViewController(animated: true)
    }

}
