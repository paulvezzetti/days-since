//
//  DateExtension.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/7/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

extension Date {
    
    // Normalizes a Date to 12:01 AM on that day
    mutating func normalize() {
        let calendar = Calendar.current
        self = calendar.startOfDay(for: self)
//        self = calendar.date(bySettingHour: 0, minute: 1, second: 0, of: self) ?? self
    }
    
    func getLongString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        formatter.timeStyle = .full
        
        return formatter.string(from: self)
    }
    
    
}
