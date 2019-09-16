//
//  EventMO+CoreDataClass.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 2/22/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData

@objc(EventMO)
public class EventMO: NSManagedObject, AsEncodable {
    
    func clone(context: NSManagedObjectContext) -> EventMO {
        let theClone = EventMO(context: context)
        theClone.timestamp = self.timestamp
        theClone.details = self.details
        theClone.image = self.image
        return theClone
    }
    
    func getFormattedDate(style:DateFormatter.Style) -> String {
        guard let eventDate = self.timestamp else {
            return ""
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = style
        dateFormatter.timeStyle = DateFormatter.Style.none
        
        return dateFormatter.string(from: eventDate)
    }
    
    func formattedDate()-> String {
        return getFormattedDate(style: .medium)
    }


    func asEncodable() -> Codable {
        var timeInterval = 0.0
        if let ts = timestamp {
            timeInterval = ts.timeIntervalSinceReferenceDate
        }
        return EventCodable(timestamp: timeInterval, details: details)
    }

    
//    deinit {
//        print("Destroying Event at \(getFormattedDate(style: DateFormatter.Style.long))")
//    }
}
