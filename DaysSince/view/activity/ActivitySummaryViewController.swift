//
//  ActivitySummaryViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/12/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class ActivitySummaryViewController: UIViewController {

    @IBOutlet var daysSinceLabel: UILabel!
    @IBOutlet var daysUntilLabel: UILabel!
    @IBOutlet var dueNextLabel: UILabel!
    @IBOutlet var expectedFrequencyLabel: UILabel!
    @IBOutlet var avgIntervalLabel: UILabel!
    @IBOutlet var maxIntervalLabel: UILabel!
    @IBOutlet var minIntervalLabel: UILabel!
    @IBOutlet var numInstancesLabel: UILabel!
    @IBOutlet var firstInstanceLabel: UILabel!
    
    var activity:ActivityMO? {
        didSet {
            NotificationCenter.default.removeObserver(self)
            // Add new observers
            DataModelManager.registerForAnyActivityChangeNotification(self, selector: #selector(onActivityChanged(notification:)), activity: activity)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        configureView()
    }
    
    func configureView() {
        guard let act = activity else {
            return
        }
        let stats:ActivityStatistics = ActivityStatistics(activity: act)
        let daysSince = stats.daySince
        let daysUntil = stats.daysUntil
        expectedFrequencyLabel.text = ""
        numInstancesLabel.text = String(act.history?.count ?? 0)
        daysSinceLabel.text = daysSince != nil ? String(stats.daySince!) : "--"
        daysUntilLabel.text = daysUntil != nil ? String(stats.daysUntil!) : "--"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = DateFormatter.Style.medium
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        dueNextLabel.text = stats.nextDay
        
        minIntervalLabel.text = String(stats.minDays)
        maxIntervalLabel.text = String(stats.maxDays)
        avgIntervalLabel.text = String(stats.avgDays)
        
        firstInstanceLabel.text = stats.firstDay

    }
    
    @objc func onActivityChanged(notification:Notification) {
        configureView()
    }
    
    func activityDidChange() {
        configureView()
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
