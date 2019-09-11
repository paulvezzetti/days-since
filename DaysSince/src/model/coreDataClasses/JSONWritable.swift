//
//  JSONWritable.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/9/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

protocol JSONWritable {
    
    func writeToJSON(writer: JSONWriter);
    
}
