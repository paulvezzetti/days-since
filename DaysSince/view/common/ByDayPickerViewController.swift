//
//  ByDayPickerViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/27/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
import UIKit
import Foundation

class ByDayPickerViewController : NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    weak var delegate:ByDayPickerDelegate?
    
    init(delegate:ByDayPickerDelegate) {
        self.delegate = delegate
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return DaysOfWeek.fromIndex(row).rawValue
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.pickerValueChanged(DaysOfWeek.fromIndex(row))
    }
    
}
