//
//  IntervalUtils.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/1/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation


class IntervalUtils {
    
    static func toPrettyString(type: IntervalTypes, day: Int, month: Int) -> String {
        
        switch type {
        case IntervalTypes.Unlimited:
            return "Whenever I feel like it"
        case IntervalTypes.Constant:
            return "Every " + String(day) + " days"
        case IntervalTypes.Weekly:
            return "Every week on " + DaysOfWeek.fromIndex(day).rawValue
        case IntervalTypes.Monthly:
            return "Every month on the "
        case IntervalTypes.Yearly:
            return "Every year on " + Months.fromIndex(month).rawValue + " " + String(day)
        }
    }
}
