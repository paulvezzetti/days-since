//
//  ScaleDateComponentPickerDelegate.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 4/4/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation
import UIKit

protocol ScaleDateComponentPickerDelegate : class {
    
    func scaleComponentsSet(component: OffsetIntervals, scale:Int)

}
