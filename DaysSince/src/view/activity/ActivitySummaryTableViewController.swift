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
    @IBOutlet var onTimePercentLabel: UILabel!
    @IBOutlet var numberOfEventsLabel: UILabel!
    @IBOutlet var firstEventDateLabel: UILabel!
    
    @IBOutlet var intervalDotPlot: IntervalDotPlotView!
    
    @IBOutlet weak var timelineView: TimelineView!
    
    var activity:ActivityMO? {
        didSet {
            NotificationCenter.default.removeObserver(self)
            // Add new observers
            DataModelManager.registerForAnyActivityChangeNotification(self, selector: #selector(onActivityChanged(notification:)), activity: activity)
            if isViewLoaded {
                configureView()
            }
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
        let lastDate = stats.lastDate
        let nextDate = stats.nextDate
        
        let percentFormatter = NumberFormatter()
        percentFormatter.numberStyle = .percent
        percentFormatter.maximumFractionDigits = 1
        onTimePercentLabel.text = percentFormatter.string(for: stats.onTimePercent)
        
        numberOfEventsLabel.text = String(act.history?.count ?? 0)
        
        firstEventDateLabel.text = stats.firstDay
        
        intervalDotPlot.intervals = stats.intervals
        
        timelineView.daysSince = stats.daySince ?? 0
        timelineView.daysUntil = stats.daysUntil != nil ? stats.daysUntil! : Int.max
        timelineView.nextDate = nextDate != nil ? nextDate!.getShortFormattedDate() : ""
        timelineView.prevDate = lastDate != nil ? lastDate!.getShortFormattedDate() : ""
        
        //timelineView.setNeedsDisplay()
    }

    
    @objc func onActivityChanged(notification:Notification) {
        configureView()
    }

}
