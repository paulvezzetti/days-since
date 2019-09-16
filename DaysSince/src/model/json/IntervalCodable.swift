//
//  IntervalCodable.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/10/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

struct IntervalCodable: Codable {
    let type: String
    let activeRange: ActiveRangeCodable?
    
    let day: Int16?
    let week: Int16?
    let month: Int16?
    let year: Int16?
    
}
