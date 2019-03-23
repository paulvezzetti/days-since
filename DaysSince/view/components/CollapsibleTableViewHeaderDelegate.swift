//
//  CollapsibleTableViewHeaderDelegate.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/22/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

protocol CollapsibleTableViewHeaderDelegate {
    
    func toggleSection(header: ActivityTableHeaderView, section: Int)
    
}
