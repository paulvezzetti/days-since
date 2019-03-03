//
//  DaysOfMonth.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/2/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

struct DaysOfMonth {
    
    private let numberFormatter:NumberFormatter
    
    init() {
        numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
    }
    
    func formattedValueForIndex(_ index: Int) -> String {
        if index <= 0 {
            return "First Day"
        }
        if index > 31 {
            return "Last Day"
        }
        return numberFormatter.string(for: index) ?? "Missing"
    }
}
