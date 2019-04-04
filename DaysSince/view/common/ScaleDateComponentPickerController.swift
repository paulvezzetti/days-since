//
//  ScaleDateComponentPicker.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/4/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation
import UIKit

class ScaleDateComponentPickerController: NSObject {
        
    
    private weak var delegate:ScaleDateComponentPickerDelegate?
    private weak var picker:UIPickerView?
    
    init(picker: UIPickerView, delegate:ScaleDateComponentPickerDelegate) {
        self.picker = picker
        self.delegate = delegate
        
        super.init()
        
        self.picker?.delegate = self
        self.picker?.dataSource = self
        
    }

}

extension ScaleDateComponentPickerController {
    
    func setScaleDateComponent(component:OffsetIntervals, scale: Int) {
        self.picker?.selectRow(scale - 1, inComponent: 0, animated: false)
        self.picker?.selectRow(component.rawValue, inComponent: 1, animated: false)
    }
    
    func getScale() -> Int {
        return (self.picker?.selectedRow(inComponent: 0) ?? 0) + 1
    }
    
    func getComponent() -> OffsetIntervals {
        let row = self.picker?.selectedRow(inComponent: 1) ?? 0
        return OffsetIntervals(rawValue: row) ?? .Week
    }
}

// MARK: UIPickerViewDataSource
extension ScaleDateComponentPickerController : UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 1 {
            return 3 // Weeks, Months or Years
        }
        return 99
//        let selectedType = pickerView.selectedRow(inComponent: 1)
//        switch selectedType {
//        case 0: // Weeks
//            return 100
//        case 1: // Months
//            return 48
//        default: // Years
//            return 10
//        }
    }
    
}
// MARK: UIPickerViewDelegate
extension ScaleDateComponentPickerController : UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if component == 1 {
            switch row {
            case 0:
                return "Weeks"
            case 1:
                return "Months"
            default:
                return "Years"
            }
        }
        
        return String(row + 1)
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let scale = pickerView.selectedRow(inComponent: 0) + 1
        
        let component = OffsetIntervals(rawValue: pickerView.selectedRow(inComponent: 1))
        delegate?.scaleComponentsSet(component: component ?? .Week, scale: scale)
    }
    
}

