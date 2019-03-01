//
//  IntervalSettingsDelegate.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/1/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

protocol IntervalSettingsDelegate {
    
    func getInitialIntervalSettings() -> (type: IntervalTypes, day: Int, month: Int)
    
    func applyIntervalSettings(type: IntervalTypes, day: Int, month: Int)
    
}
