//
//  YearDayPickerController.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/27/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
import UIKit
import Foundation

class YearDayPickerController: NSObject {
    
    private weak var delegate:YearDayPickerDelegate?
    private weak var picker:UIPickerView?
    
    init(picker: UIPickerView, delegate:YearDayPickerDelegate) {
        self.picker = picker
        self.delegate = delegate
        
        super.init()
        
        self.picker?.delegate = self
        self.picker?.dataSource = self
        
    }
    
}

// MARK : Public

extension YearDayPickerController {
    
    func setYearDay(month: Int, day:Int) {
        // Months are 1-12, rows are 0-11
        self.picker?.selectRow(month - 1, inComponent: 0, animated: false)
        self.picker?.selectRow(day - 1, inComponent: 1, animated: false)
    }
    
    func getMonth() -> Int {
        return (self.picker?.selectedRow(inComponent: 0) ?? 0) + 1
    }
    
    func getDay() -> Int {
        return (self.picker?.selectedRow(inComponent: 1 ) ?? 0) + 1
    }
}


// MARK: UIPickerViewDataSource
extension YearDayPickerController : UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 12
        }
        
        return Months.daysInMonth(month: pickerView.selectedRow(inComponent: 0) + 1)
    }

}
// MARK: UIPickerViewDelegate
extension YearDayPickerController : UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 0 {
            return Months.month(for: row + 1)
        }
        
        return String(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            pickerView.reloadComponent(1)
        }
        let selectedMonth = pickerView.selectedRow(inComponent: 0) + 1
        delegate?.yearDaySet(month: selectedMonth, monthSymbol: Months.month(for: selectedMonth), day: pickerView.selectedRow(inComponent: 1) + 1)
    }

}
