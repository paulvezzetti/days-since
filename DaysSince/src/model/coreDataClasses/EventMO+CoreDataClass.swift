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
public class EventMO: NSManagedObject, JSONExportable {
    

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

    func writeJSON() -> String {
        var json = ""
        if let ts = timestamp {
            json = JSONUtilities.writeProperty(name: "timestamp", property: ts.timeIntervalSinceReferenceDate)
        }
        if let detailStr = details {
            json = JSONUtilities.appendProperty(json, name: "details", property: detailStr)
        }
        return json
    }

    
    
//    deinit {
//        print("Destroying Event at \(getFormattedDate(style: DateFormatter.Style.long))")
//    }
}
