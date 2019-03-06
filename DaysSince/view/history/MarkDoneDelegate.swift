//
//  MarkDoneDelegate.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 3/6/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation
import UIKit

protocol MarkDoneDelegate {
    
    func done(at date:Date, withDetails details:String, sender: UIViewController)
    
    func cancelled(sender: UIViewController)
}
