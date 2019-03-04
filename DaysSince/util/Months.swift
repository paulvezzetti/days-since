//
//  Months.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/4/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

struct Months {
    
    static let calendar:Calendar = Calendar.current
    
    static func allMonths() -> [String] {
        return calendar.monthSymbols
    }
    
    static func month(for index:Int) -> String {
        let months = calendar.monthSymbols
        return months[index - 1]
    }
    static func index(for month:String) -> Int {
        let months = calendar.monthSymbols
        return months.firstIndex(of: month)! + 1
    }

    
}
