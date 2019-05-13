//
//  NumberFormatterOrdinal.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/19/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

struct NumberFormatterOrdinal {
    
    static func string(_ value:Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .ordinal
        return numberFormatter.string(for: value) ?? String(value)
    }
    
}
