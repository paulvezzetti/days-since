//
//  TimePickerView.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 6/7/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import UIKit

class TimePickerView: UIView {

    
    @IBOutlet var doneButton: UIButton!
    @IBOutlet var timePicker: UIDatePicker!
    @IBOutlet var contentView: TimePickerView!
    
    var delegate:TimePickerViewDelegate?
    var initialDate:Date? {
        didSet {
            guard let picker = timePicker, let initDate = initialDate else {
                return;
            }
            picker.date = initDate
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        Bundle.main.loadNibNamed("TimePickerView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        contentView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    @IBAction func onDoneButtonPress(_ sender: Any) {
        guard let del = delegate else {
            return;
        }
        del.done(selected: timePicker.date)
    }
    
    @IBAction func onTimePickerValueChanged(_ sender: Any) {
        guard let del = delegate else {
            return;
        }
        del.timeValueChange(to: timePicker.date)

    }
}
