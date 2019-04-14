//
//  ActivityInfoTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/10/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ActivityInfoTableViewController: UITableViewController {

    enum TableRows:Int {
        case Due = 0,
        Range,
        ReminderEnabled,
        ReminderBefore,
        SnoozeEnabled,
        SnoozeFor,
        LastSnooze
    }

    @IBOutlet var dueLabel: UILabel!
    @IBOutlet var activeRangeLabel: UILabel!
    @IBOutlet var remindersStatusLabel: UILabel!
    @IBOutlet var reminderSettingsLabel: UILabel!
    @IBOutlet var snoozeEnabledLabel: UILabel!
    @IBOutlet var snoozeIntervalLabel: UILabel!
    @IBOutlet var lastSnoozeLabel: UILabel!
    
    var activity:ActivityMO? {
        didSet {
            NotificationCenter.default.removeObserver(self)
            // Add new observers
            DataModelManager.registerForAnyActivityChangeNotification(self, selector: #selector(onActivityChanged(notification:)), activity: activity)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureView();
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    func configureView() {
        guard let act = activity else {
            return
        }
        dueLabel.text = act.interval?.toPrettyString()
        if let activeRange = act.interval?.activeRange {
            activeRangeLabel.text = activeRange.toPrettyString()
        } else {
            activeRangeLabel.text = "All Year"
        }
        if let reminder = act.reminder {
            remindersStatusLabel.text = reminder.enabled ? "ON" : "OFF"
            if reminder.enabled {
                reminderSettingsLabel.text = reminder.daysBefore == 1 ? "1 day before" : String(reminder.daysBefore) + " days before"
            } else {
                reminderSettingsLabel.text = ""
            }
            snoozeEnabledLabel.text = reminder.allowSnooze ? "ON" : "OFF"
            if reminder.allowSnooze {
                snoozeIntervalLabel.text = reminder.snooze == 1 ? "For 1 day" : "For " + String(reminder.snooze) + " days"
                if let lastSnooze = reminder.lastSnooze {
                    lastSnoozeLabel.text = "Last snooze on " + lastSnooze.getFormattedDate()
                } else {
                    lastSnoozeLabel.text = ""
                }
            } else {
                snoozeIntervalLabel.text = ""
                lastSnoozeLabel.text = ""
            }
        } else {
            remindersStatusLabel.text = "OFF"
            reminderSettingsLabel.text = ""
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        //print("Height for row: \(indexPath.row)")
        guard let act = activity, let reminder = act.reminder else {
            return super.tableView(tableView, heightForRowAt: indexPath)
        }
        
        if indexPath.row == TableRows.ReminderBefore.rawValue && !reminder.enabled {
            return 0
        }
        
        if (indexPath.row == TableRows.SnoozeFor.rawValue || indexPath.row == TableRows.LastSnooze.rawValue) && !reminder.allowSnooze {
            return 0
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }

    
    @objc func onActivityChanged(notification:Notification) {
        configureView()
    }

}
