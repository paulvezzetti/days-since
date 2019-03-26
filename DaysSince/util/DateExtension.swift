//
//  DateExtension.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/7/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

extension Date {
    
    // Normalizes a Date to 12:00 AM on that day
    mutating func normalize() {
//        let calendar = Calendar.current
//        self = calendar.startOfDay(for: self)
        self = Date.normalize(date: self)
    }
    
    static func normalize(date:Date) -> Date {
        let calendar = Calendar.current
        return calendar.startOfDay(for:date)
    }
    
    func getFullString() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        //formatter.timeStyle = .full
        
        return formatter.string(from: self)
    }
    
    func getFormattedDate() -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        
        return formatter.string(from: self)
    }
    
    
}
