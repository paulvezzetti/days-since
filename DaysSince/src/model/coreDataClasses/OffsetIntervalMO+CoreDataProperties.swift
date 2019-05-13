//
//  OffsetIntervalMO+CoreDataProperties.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/4/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//
//

import Foundation
import CoreData


extension OffsetIntervalMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OffsetIntervalMO> {
        return NSFetchRequest<OffsetIntervalMO>(entityName: "OffsetInterval")
    }

    @NSManaged public var offset: Int16

}
