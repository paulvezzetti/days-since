//
//  UITextFieldUtility.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 5/13/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation
import UIKit

class UITextFieldUtility {
    
    
    static func getAsInt(textField:UITextField?, defaultValue:Int, minimumValue:Int = 0, maximumValue:Int = Int.max) -> Int {
        guard let field = textField, let inputText = field.text else {
            return defaultValue
        }

        let returnValue = Int(inputText) ?? defaultValue
        if returnValue < minimumValue {
            return minimumValue
        } else if returnValue > maximumValue {
            return maximumValue
        }
        return returnValue
    }
    
    
}
