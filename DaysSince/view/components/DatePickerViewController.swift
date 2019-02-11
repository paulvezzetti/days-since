//
//  DatePickerViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/9/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class DatePickerViewController: UIViewController {

    @IBOutlet var datePicker: UIDatePicker!
    
    @IBAction func onDoneSelected(_ sender: Any) {
        if var dpDelegate = delegate {
            dpDelegate.chosenDate = datePicker.date
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    var delegate:DatePickerDelegate?
    var initialDate: Date?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let initDate = initialDate {
            datePicker.date = initDate
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
