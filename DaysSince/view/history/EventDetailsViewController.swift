//
//  EventDetailsViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/6/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class EventDetailsViewController: UIViewController {

    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var intervalLabel: UILabel!
    @IBOutlet var detailTextView: UITextView!
    var event:EventMO?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let currentEvent = event {
            dateLabel.text = currentEvent.getFormattedDate(style: .long)
            detailTextView.text = currentEvent.details
        }
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
