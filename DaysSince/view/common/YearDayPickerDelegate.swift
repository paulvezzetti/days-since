//
//  YearDayPickerDelegate.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/28/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

protocol YearDayPickerDelegate : class {
    
    func yearDaySet(month:Int, monthSymbol:String, day: Int)
}
