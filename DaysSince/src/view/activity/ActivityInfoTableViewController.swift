//
//  ActivityInfoTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/10/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ActivityInfoTableViewController: UITableViewController, ActivityBased {

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
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }

    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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

extension ActivityInfoTableViewController {
    
    private func configureView() {
        guard let act = activity else {
            return
        }
        dueLabel.text = act.interval?.toPrettyString()
        if let activeRange = act.interval?.activeRange {
            activeRangeLabel.text = activeRange.toPrettyString()
        } else {
            activeRangeLabel.text = ActiveRangeMO.getStringForNil()
        }
        if let reminder = act.reminder {
            remindersStatusLabel.text = reminder.enabled ? NSLocalizedString("on", value: "ON", comment: "") : NSLocalizedString("off", value: "OFF", comment: "")
            if reminder.enabled {
                reminderSettingsLabel.text = String.localizedStringWithFormat(NSLocalizedString("reminder.label.string", comment: ""), reminder.daysBefore)
            } else {
                reminderSettingsLabel.text = ""
            }
            snoozeEnabledLabel.text = reminder.allowSnooze ? NSLocalizedString("on", value: "ON", comment: "") : NSLocalizedString("off", value: "OFF", comment: "")
            if reminder.allowSnooze {
                snoozeIntervalLabel.text = String.localizedStringWithFormat(NSLocalizedString("snooze.label.string", comment: ""), reminder.snooze)
                if let lastSnooze = reminder.lastSnooze {
                    lastSnoozeLabel.text = String.localizedStringWithFormat(NSLocalizedString("lastSnoozeOn.msg", value: "Last snooze on %@", comment: ""), lastSnooze.getFormattedDate());
                } else {
                    lastSnoozeLabel.text = ""
                }
            } else {
                snoozeIntervalLabel.text = ""
                lastSnoozeLabel.text = ""
            }
        } else {
            remindersStatusLabel.text = NSLocalizedString("off", value: "OFF", comment: "")
            reminderSettingsLabel.text = ""
        }
    }

}
