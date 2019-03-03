//
//  ByYearDayPickerController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/27/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
import UIKit
import Foundation

class ByYearDayPickerController: NSObject, UIPickerViewDataSource, UIPickerViewDelegate {
    
    private weak var delegate:ByYearDayPickerDelegate?
    
    private let numDays: [Int : Int ] = [
        0:31,
        1:29,
        2:31,
        3:30,
        4:31,
        5:30,
        6:31,
        7:31,
        8:30,
        9:31,
        10:30,
        11:31
    ]
    
    init(delegate:ByYearDayPickerDelegate) {
        self.delegate = delegate
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 12
        }
        let selectedMonth = pickerView.selectedRow(inComponent: 0)
        return numDays[selectedMonth] ?? 31
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return Months.fromIndex(row).rawValue
        }
        
        return String(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
        delegate?.pickerValueChanged(month: pickerView.selectedRow(inComponent: 0), day: pickerView.selectedRow(inComponent: 1))
    }
    
    
}
