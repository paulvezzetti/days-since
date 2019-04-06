//
//  YearDayPickerDelegate.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/28/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation
import UIKit

protocol YearDayPickerDelegate : class {
    
    func yearDaySet(picker:UIPickerView, month:Int, monthSymbol:String, day: Int)
}
