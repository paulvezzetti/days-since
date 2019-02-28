//
//  Months.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/28/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

enum Months:String {
    
    case January,
    February,
    March,
    April,
    May,
    June,
    July,
    August,
    September,
    October,
    November,
    December
    
    
    static func asArray() -> [String] {
        return [
            Months.January.rawValue,
            Months.February.rawValue,
            Months.March.rawValue,
            Months.April.rawValue,
            Months.May.rawValue,
            Months.June.rawValue,
            Months.July.rawValue,
            Months.August.rawValue,
            Months.September.rawValue,
            Months.October.rawValue,
            Months.November.rawValue,
            Months.December.rawValue
        ]
    }
    
    static func fromIndex(_ index: Int) -> Months {
        switch (index) {
        case 0:
            return Months.January
        case 1:
            return Months.February
        case 2:
            return Months.March
        case 3:
            return Months.April
        case 4:
            return Months.May
        case 5:
            return Months.June
        case 6:
            return Months.July
        case 7:
            return Months.August
        case 8:
            return Months.September
        case 9:
            return Months.October
        case 10:
            return Months.November
        case 11:
            return Months.December
        default:
            return Months.January
        }
    }


    
}
