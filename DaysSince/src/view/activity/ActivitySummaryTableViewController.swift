//
//  ActivitySummaryTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/1/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ActivitySummaryTableViewController: UITableViewController {
    
    
    @IBOutlet var intervalHeaderLabel: UILabel!
//    @IBOutlet var daySinceValueLabel: UILabel!
//    @IBOutlet var daysUntilValueLabel: UILabel!
//    @IBOutlet var daysUntilLabelLabel: UILabel!
//    
//    @IBOutlet var eventTimelineImage: UIImageView!
//    @IBOutlet var previousDateLabel: UILabel!
//    @IBOutlet var nextDateLabel: UILabel!
    @IBOutlet var onTimePercentLabel: UILabel!
    @IBOutlet var numberOfEventsLabel: UILabel!
    @IBOutlet var firstEventDateLabel: UILabel!
    
    
    @IBOutlet var intervalDotPlot: IntervalDotPlotView!
    @IBOutlet var statusIndicatorView: StatusIndicatorView!
    
    var activity:ActivityMO? {
        didSet {
            NotificationCenter.default.removeObserver(self)
            // Add new observers
            DataModelManager.registerForAnyActivityChangeNotification(self, selector: #selector(onActivityChanged(notification:)), activity: activity)
        }
    }

    

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        configureView()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 5 //section == 0 ? 4 : 5
    }

//    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        if section == 0 {
//            return activity?.interval?.toPrettyString()
//        }
//        return "Intervals"
//    }

    
    func configureView() {
        guard let act = activity else {
            return
        }
        // TODO: Set the section header
        //intervalLabel.text = "Due: " + (act.interval?.toPrettyString() ?? "")
        intervalHeaderLabel.text = (act.interval?.toPrettyString() ?? "")
        
        let stats:ActivityStatistics = ActivityStatistics(activity: act)
//        let daysSince = stats.daySince
//        daySinceValueLabel.text = daysSince != nil ? String(stats.daySince!) : "--"
        
//        let daysUntil = stats.daysUntil
//        daysUntilValueLabel.text = daysUntil != nil ? String(abs(stats.daysUntil!)) : ""
        
        let lastDate = stats.lastDate
//        previousDateLabel.text = lastDate != nil ? lastDate!.getFormattedDate() : NSLocalizedString("none", value: "None", comment: "")
        
        let nextDate = stats.nextDate
//        nextDateLabel.text = nextDate != nil ? nextDate!.getFormattedDate() : ""
        
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.maximumFractionDigits = 1
        onTimePercentLabel.text = percentFormatter.string(for: stats.onTimePercent)
        
//        let numberFormatter = NumberFormatter()
//        numberFormatter.maximumFractionDigits = 1
//        minIntervalLabel.text = String(stats.minDays)
//        avgIntervalLabel.text = numberFormatter.string(for: stats.avgDays)
//        maxIntervalLabel.text = String(stats.maxDays)
        
        numberOfEventsLabel.text = String(act.history?.count ?? 0)
        
        firstEventDateLabel.text = stats.firstDay
        
//        if act.interval is UnlimitedIntervalMO {
//            eventTimelineImage.image = UIImage(named: "UnlimitedArrow")
//
//        } else if nextDate != nil && nextDate! < Date() {
//            eventTimelineImage.image = UIImage(named: "OverdueArrow")
//            daysUntilLabelLabel.text = NSLocalizedString("daysOverdue.prompt", value: "Days Overdue:", comment: "")
//        } else {
//            eventTimelineImage.image = UIImage(named: "OnTimeArrow")
//            daysUntilLabelLabel.text = NSLocalizedString("daysUntil.prompt", value: "Days Until:", comment: "")
//        }
//
//        let isUnlimited = act.interval is UnlimitedIntervalMO
//        daysUntilLabelLabel.isHidden = isUnlimited
        
        
        intervalDotPlot.intervals = stats.intervals
        
        statusIndicatorView.daysSince = stats.daySince ?? 0
        statusIndicatorView.daysUntil = stats.daysUntil != nil ? stats.daysUntil! : Int.max
        statusIndicatorView.nextDate = nextDate != nil ? nextDate!.getFormattedDate() : ""
        statusIndicatorView.prevDate = lastDate != nil ? lastDate!.getFormattedDate() : ""
    }

    
    @objc func onActivityChanged(notification:Notification) {
        configureView()
    }

}
