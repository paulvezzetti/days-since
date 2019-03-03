//
//  ByMonthDayPickerController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/27/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
import UIKit
import Foundation

class ByMonthDayPickerController: NSObject, UIPickerViewDelegate, UIPickerViewDataSource {
    
    private let delegate:ByMonthDayPickerDelegate
    
    private let options: [String]
    
    init(delegate: ByMonthDayPickerDelegate) {
        self.delegate = delegate

        let daysOfMonth = DaysOfMonth()
        var values: [String] = []
        for i in 0...32 {
            values.append(daysOfMonth.formattedValueForIndex(i))
        }
        options = values
        
        super.init()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate.pickerValueChanged(row, formattedValue: options[row])
    }
    
}
