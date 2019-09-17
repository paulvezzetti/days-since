//
//  EventCodable.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/10/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
import CoreData
import Foundation

struct EventCodable: Codable {
    
    let timestamp: Double
    let details: String?
    
    func toEventMO(moc:NSManagedObjectContext) -> EventMO? {
        let event = EventMO(context: moc)
        event.timestamp = Date(timeIntervalSinceReferenceDate: timestamp)
        event.details = details
        return event
    }
}
