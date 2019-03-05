//
//  MonthDayPickerController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/27/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
import UIKit
import Foundation

class MonthDayPickerController: NSObject {
    
    // MARK: Private
    private weak var delegate:MonthDayPickerDelegate?
    private weak var picker:UIPickerView?
    private let daysOfMonth:DaysOfMonth
    private let options: [String]
    
    init(picker:UIPickerView, delegate: MonthDayPickerDelegate) {
        self.picker = picker
        self.delegate = delegate

        daysOfMonth = DaysOfMonth()
        
        var values: [String] = []
        for i in 0...32 {
            values.append(daysOfMonth.formattedValueForIndex(i))
        }
        options = values
        
        super.init()
        
        self.picker?.dataSource = self
        self.picker?.delegate = self
        
    }
    
}

// MARK: Public
extension MonthDayPickerController {
    
    func setDay(_ day:Int) {
        picker?.selectRow(day, inComponent: 0, animated: false)
    }
    
    func getDay() -> Int {
        return picker?.selectedRow(inComponent: 0) ?? 0
    }
}

// MARK: UIPickerViewDataSource
extension MonthDayPickerController : UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return options.count
    }

}
// MARK: UIPickerViewDelegate
extension MonthDayPickerController : UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?
    {
        return options[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.monthDaySet(row, formattedValue: options[row])
    }

}
