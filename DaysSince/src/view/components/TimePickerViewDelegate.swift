//
//  TimePickerViewDelegate.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 6/7/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation



protocol TimePickerViewDelegate {
    
    func timeValueChange(to date:Date, picker:TimePickerView)
    
    func done(selected date: Date, picker:TimePickerView)
}
