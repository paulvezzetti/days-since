//
//  HistoryTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/12/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class HistoryTableViewController: UITableViewController {

    var sortedHistory: [EventMO] = []
    var activity: ActivityMO? {
        didSet {
            NotificationCenter.default.removeObserver(self)
            // Add new observers
            NotificationCenter.default.addObserver(self, selector: #selector(onActivityChanged(notification:)), name: Notification.Name.activityChanged, object: activity)
            NotificationCenter.default.addObserver(self, selector: #selector(onActivityChanged(notification:)), name: Notification.Name.eventAdded, object: activity)
            NotificationCenter.default.addObserver(self, selector: #selector(onActivityChanged(notification:)), name: Notification.Name.eventRemoved, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(onEventChanged(notification:)), name: Notification.Name.eventChanged, object: nil)

            if let act = activity {
                sortedHistory = act.history?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)]) as! [EventMO]
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem

    }
    

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
            cell.intervalLabel!.text = ""
            cell.dateLabel!.text = event.getFormattedDate(style: .long)
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
        
        let action = UIContextualAction(style: .normal, title: "Delete") { (action, view, completion) in
            let alert = UIAlertController(title: "Delete this event?", message: "This will permanently delete this event from the activity history.", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "Yes", style: .destructive) { (alert) in
                let event = self.sortedHistory.remove(at: indexPath.row)
                self.activity?.deleteEvent(event: event)
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

    @objc func onActivityChanged(notification:Notification) {
        if let act = activity {
            sortedHistory = act.history?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)]) as! [EventMO]
        }
        tableView.reloadData()
    }
    
    @objc func onEventChanged(notification:Notification) {
        // TODO: This could be more granular
        if let act = activity {
            sortedHistory = act.history?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)]) as! [EventMO]
        }
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
            }
        }

    }
    
}

