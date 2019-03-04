//
//  ByDayPickerDelegate.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/28/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

protocol WeekDayPickerDelegate : class {
    
    func weekdayChosen(day:Int, symbol:String)
}
