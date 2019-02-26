//
//  ActivityExtension.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/22/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

extension ActivityMO {
    
//    enum SectionIndex: Int {
//        case onTime = 0, soon, overdue
//    }
//    
//    var status:SectionIndex {
//        return isOverdue ? SectionIndex.overdue : SectionIndex.onTime
//    }
//    
//    var isOverdue: Bool {
//        let intervalFreq = frequencyInSeconds
//        if intervalFreq == 0 {
//            return false // No frequency set, so it's never overdue
//        }
//
//        let history = sortedHistory
//        
//        guard let lastEvent = history.last else {
//            return false
//        }
//        let due = lastEvent.timestamp?.addingTimeInterval(intervalFreq)
//        return due! < Date();
//    }
//    
//    var sortedHistory: [EventMO] {
//        return history?.sortedArray(using: [NSSortDescriptor(key: "timestamp", ascending: true)]) as! [EventMO]
//    }
//    
//    private var frequencyInSeconds: Double {
//        return Double(frequency) * TimeConstants.SECONDS_PER_DAY
//    }
}
