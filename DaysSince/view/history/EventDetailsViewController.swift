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
    var delegate:EventChangeDelegate?
    var isUpdated:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTextView.layer.cornerRadius = 5
        detailTextView.layer.shadowColor = UIColor.lightGray.cgColor
       // detailTextView.layer.borderColor = UIColor.lightGray.cgColor
        detailTextView.layer.borderWidth = 1

        // Do any additional setup after loading the view.
        if let currentEvent = event {
            dateLabel.text = currentEvent.getFormattedDate(style: .long)
            detailTextView.text = currentEvent.details
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let eventDelegate = delegate, let e = event else {
            return
        }
        if isUpdated {
            eventDelegate.eventChanged(event: e)
        }
    }
    

    @IBAction func updateEvent(_ sender: Any) {
        if detailTextView.text != event?.details {
            event?.details = detailTextView.text
            isUpdated = true
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