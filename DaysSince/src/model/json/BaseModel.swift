//
//  BaseModel.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/10/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

struct BaseModel: Codable {
    
    let activities: [ActivityCodable]
}
