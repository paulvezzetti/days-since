//
//  ActivityBased.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 6/12/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

///
// Any object that uses an ActivityMO for its configuration or display.
protocol ActivityBased {
    
    var activity:ActivityMO? { get set }
    
}
