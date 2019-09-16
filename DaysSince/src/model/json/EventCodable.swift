//
//  EventCodable.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/10/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

struct EventCodable: Codable {
    
    let timestamp: Double
    let details: String?
}
