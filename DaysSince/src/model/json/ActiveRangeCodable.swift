//
//  ActiveRangeCodable.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/10/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

struct ActiveRangeCodable: Codable {
    
    let startDay: Int16
    let startMonth: Int16
    let endDay: Int16
    let endMonth: Int16
}
