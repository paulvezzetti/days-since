//
//  HistoryTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/12/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController, ActivityBased, DataModelManagerRequired {

    var sortedHistory: [EventMO] = []
    var activity: ActivityMO? {
        didSet {
            NotificationCenter.default.removeObserver(self)
            // Add new observers
            DataModelManager.registerForNamedNotifications(self, selector: #selector(onActivityChanged(notification:)), names: [.activityChanged, .eventAdded, .eventRemoved], object: activity)
            NotificationCenter.default.addObserver(self, selector: #selector(onEventChanged(notification:)), name: Notification.Name.eventChanged, object: activity)

            sortHistory()
            tableView.reloadData()
        }
    }
    var dataManager:DataModelManager?
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        guard let act = activity else {
            return 0
        }
        return act.history?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "historyCell", for: indexPath) as! HistoryTableViewCell
        
        // Configure the cell...
//        guard let act = activity else {
//            return cell
//        }
        
        if indexPath.row < sortedHistory.count {
            let event:EventMO = self.sortedHistory[indexPath.row]
            cell.detailsLabel!.text = event.details
            if event.daysSincePrevious >= 0 {
                cell.intervalLabel!.text = String(event.daysSincePrevious)
                if event.isOnTime {
                    //cell.intervalLabel!.textColor = UIColor.black
                    cell.daysOverdueLabel.text = ""
                } else {
                    //cell.daysOverdueLabel!.textColor = UIColor.red
                    cell.daysOverdueLabel!.text = String(event.daysOverdue)
                }
            } else {
                cell.intervalLabel!.text = ""
            }
            cell.dateLabel!.text = event.getFormattedDate(style: .medium)
        }
//        cell.textLabel!.text = "History"
        return cell
    }
    
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if sortedHistory.count <= 1 {
            return UISwipeActionsConfiguration(actions: [])
        }
        let delete = deleteAction(at: indexPath)
        return UISwipeActionsConfiguration(actions: [delete])
    }

    func deleteAction(at indexPath: IndexPath) -> UIContextualAction {
        
        let action = UIContextualAction(style: .normal, title: NSLocalizedString("delete", value: "Delete", comment: "")) { (action, view, completion) in
            let alert = UIAlertController(title: NSLocalizedString("deleteEvent.title", value: "Delete this event?", comment: ""),
                                          message: NSLocalizedString("deleteEvent.msg", value: "This will permanently delete this event from the activity history.", comment: ""), preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: NSLocalizedString("delete", value: "Delete", comment: ""), style: .destructive) { [unowned self](alert) in
                guard indexPath.row < self.sortedHistory.count, let activity = self.activity, let dm = self.dataManager else {
                    return
                }
                let event = self.sortedHistory.remove(at: indexPath.row)
                do {
                    try dm.removeEvent(activity: activity, event: event)
                } catch {
                    // TODO: Delete failed?
                }
            })
            alert.addAction(UIAlertAction(title: NSLocalizedString("cancel", value: "Cancel", comment: ""), style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            completion(true)
        }
        action.image = UIImage(named: "trash")
        action.backgroundColor = .red
        return action
    }

    @objc func onActivityChanged(notification:Notification) {
        sortHistory()
        tableView.reloadData()
    }
    
    @objc func onEventChanged(notification:Notification) {
        // TODO: This could be more granular
        sortHistory()
        tableView.reloadData()
        
        // TODO: Do we need some central save controller logic
        
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    private func sortHistory() {
        if let act = activity {
            sortedHistory = act.history?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: false)]) as! [EventMO]
            
            // Update transient values for interval and onTime status. Need to redo this since events can be inserted anywhere in the history
            var previousEvent:EventMO? = nil
            let calendar = Calendar.current
            for event in sortedHistory.reversed() {
                if previousEvent == nil {
                    previousEvent = event
                    previousEvent?.daysSincePrevious = -1
                    continue;
                }
                let days = calendar.dateComponents([.day], from: previousEvent!.timestamp!, to: event.timestamp!)
                event.daysSincePrevious = Int16(days.day ?? 0)
                // TODO: Use days overdue instead of isOnTime. Put total days and days overdue on table cell
                if let nextExpectedDate = act.interval?.getNextDate(since: previousEvent!.timestamp!) {
                    event.isOnTime = (calendar.compare(event.timestamp!, to: nextExpectedDate, toGranularity: .day) != .orderedDescending)
                    let daysOverdue = calendar.dateComponents([.day], from: nextExpectedDate, to: event.timestamp!)
                    event.daysOverdue = Int16(daysOverdue.day ?? 0)
                } else {
                    event.isOnTime = true
                    event.daysOverdue = 0
                }
                previousEvent = event
            }
            
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if segue.identifier == "showHistoryDetail" {
            
            //destination.event = tableView.sele
            guard let destination = segue.destination as? EventDetailsViewController,
                let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            if indexPath.row < sortedHistory.count {
                destination.event = sortedHistory[indexPath.row]
                destination.dataManager = dataManager
            }
        }

    }
    
}

