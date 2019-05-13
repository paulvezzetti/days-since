//
//  Weekdays.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/4/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

struct Weekdays {
    
    static let calendar:Calendar = Calendar.current
    
    static func allDays() -> [String] {
        return calendar.weekdaySymbols
    }
    
    static func day(for index:Int) -> String {
        let days = calendar.weekdaySymbols
        return days[index - 1]
    }
    static func index(for day:String) -> Int {
        let days = calendar.weekdaySymbols
        return days.firstIndex(of: day)! + 1
    }
}
