//
//  ActiveRangeCodable.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/10/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
import CoreData
import Foundation

struct ActiveRangeCodable: Codable {
    
    let startDay: Int16
    let startMonth: Int16
    let endDay: Int16
    let endMonth: Int16
    
    func toActiveRangeMO(moc:NSManagedObjectContext) -> ActiveRangeMO? {
        let range = ActiveRangeMO(context: moc)
        range.startDay = startDay
        range.startMonth = startMonth
        range.endDay = endDay
        range.endMonth = endMonth
        return range
    }
}
