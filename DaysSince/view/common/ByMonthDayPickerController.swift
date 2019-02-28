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
    
    private let options: [String] =  {
        var values: [String] = []
        values.append("First Day")
        values.append("Last Day")
        for i in 1...31 {
            values.append(String(i))
        }
        return values
    }()
    
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
    
    
    
}
