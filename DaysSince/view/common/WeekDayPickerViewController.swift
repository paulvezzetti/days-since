//
//  ByDayPickerViewController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/27/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
import UIKit
import Foundation

class WeekDayPickerViewController : NSObject {
    
    private weak var delegate:WeekDayPickerDelegate?
    private weak var picker: UIPickerView?
    
    init(picker: UIPickerView, delegate:WeekDayPickerDelegate) {
        self.picker = picker
        self.delegate = delegate
        
        super.init()
        
        self.picker?.dataSource = self
        self.picker?.delegate = self
    }
}

// MARK : Public

extension WeekDayPickerViewController {
    
    func setWeekday(to index:Int) {
        // Weekdays are 1-7. Row indices are 0-6
        self.picker?.selectRow(index - 1, inComponent: 0, animated: false)
    }
    
    func getWeekday() -> Int {
        return (self.picker?.selectedRow(inComponent: 0) ?? 0) + 1
    }
}
// MARK: UIPickerViewDataSource

extension WeekDayPickerViewController: UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return 7
    }
    
}

// MARK: UIPickerViewDelegate

extension WeekDayPickerViewController: UIPickerViewDelegate {

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return Weekdays.day(for: row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        delegate?.weekdayChosen(day: row + 1, symbol: Weekdays.day(for: row + 1))
    }

}
