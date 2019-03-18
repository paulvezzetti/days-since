//
//  MarkDoneTableViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/5/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class MarkDoneTableViewController: UITableViewController {

    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var detailTextView: UITextView!
    
    var activity:ActivityMO?
    
    
    private let dateFormatter:DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        formatter.timeStyle = DateFormatter.Style.none
        return formatter
    }()

    var doneDelegate:MarkDoneDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        datePicker.date = Date()
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : 1
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
 */
    
    @IBAction func onDatePickerValueChange(_ sender: Any) {
//        dateLabel.text = dateFormatter.string(from: datePicker.date)
    }
    
    @IBAction func cancel(_ sender: Any) {
        if let delegate = doneDelegate {
            delegate.cancelled(sender: self)
        }
    }
    
    
    
    @IBAction func markDone(_ sender: Any) {
        
        if let act = activity, let moc = act.managedObjectContext {
            let event = EventMO(context: moc)
            event.timestamp = Date.normalize(date: datePicker.date)
            event.details = detailTextView.text!
            act.addToHistory(event)
        }

        if let delegate = doneDelegate {
            delegate.done(at: datePicker.date, withDetails: detailTextView.text!, sender: self)
        }
    }
}
