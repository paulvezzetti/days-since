//
//  DaysOfWeek.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/28/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation


enum DaysOfWeek: String {
    
    case Monday,
    Tuesday,
    Wednesday,
    Thursday,
    Friday,
    Saturday,
    Sunday
    
    
    static func asArray() -> [String] {
        return [
        DaysOfWeek.Monday.rawValue,
        DaysOfWeek.Tuesday.rawValue,
        DaysOfWeek.Wednesday.rawValue,
        DaysOfWeek.Thursday.rawValue,
        DaysOfWeek.Friday.rawValue,
        DaysOfWeek.Saturday.rawValue,
        DaysOfWeek.Sunday.rawValue
        ]
    }
    
    static func fromIndex(_ index: Int) -> DaysOfWeek {
        switch (index) {
        case 0:
            return DaysOfWeek.Monday
        case 1:
            return DaysOfWeek.Tuesday
        case 2:
            return DaysOfWeek.Wednesday
        case 3:
            return DaysOfWeek.Thursday
        case 4:
            return DaysOfWeek.Friday
        case 5:
            return DaysOfWeek.Saturday
        case 6:
            return DaysOfWeek.Sunday
        default:
            return DaysOfWeek.Monday
        }
    }
    
    func asInt() -> Int {
        switch self {
        case DaysOfWeek.Monday:
            return 0
        case DaysOfWeek.Tuesday:
            return 1
        case DaysOfWeek.Wednesday:
            return 2
        case DaysOfWeek.Thursday:
            return 3
        case DaysOfWeek.Friday:
            return 4
        case DaysOfWeek.Saturday:
            return 5
        case DaysOfWeek.Sunday:
            return 6
        }
    }
    
}
