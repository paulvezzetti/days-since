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
    var dataManager:DataModelManager?
    
    var isUpdated:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailTextView.layer.cornerRadius = 5
//        detailTextView.layer.shadowColor = UIColor.lightGray.cgColor
//        detailTextView.layer.shadowOpacity = 0.2
        detailTextView.layer.borderColor = UIColor.init(red: 0.2, green: 0.2, blue: 0.2, alpha: 0.2).cgColor
        detailTextView.layer.borderWidth = 1

        // Do any additional setup after loading the view.
        if let currentEvent = event {
            dateLabel.text = currentEvent.getFormattedDate(style: .long)
            if currentEvent.activity != nil {
                let numDays = currentEvent.activity!.daysSincePreviousEvent(event: currentEvent)
                if numDays < 0 {
                    intervalLabel.text = "No previous event"
                } else {
                    intervalLabel.text = String(numDays) + " days between events"
                }
            }
            detailTextView.text = currentEvent.details
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        guard let e = event else {
            return
        }
        if isUpdated {
            if let moc = e.managedObjectContext {
                do {
                    try moc.save()
                } catch {
                    
                }
            }
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
