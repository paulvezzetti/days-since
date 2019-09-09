//
//  JSONUtilities.swift
//  DaysSince
//
//  Created by Paul Vezzetti on 9/8/19.
//  Copyright © 2019 Paul Vezzetti. All rights reserved.
//

import Foundation

class JSONUtilities {

    static func appendProperty<T: CustomStringConvertible>(_ current:String, name:String, property:T) -> String {
        let propertyStr = writeProperty(name: name, property: property)
        return current.isEmpty ? propertyStr : "\(current),\(propertyStr)"
    }
    
//    static func appendProperty(_ current:String, name:String, property:String) -> String {
//        let propertyStr = writeProperty(name: name, property: property)
//        return current.isEmpty ? propertyStr : "\(current),\(propertyStr)"
//    }
//    
//    static func appendProperty(_ current:String, name: String, property:Int16) -> String {
//        let propStr = writeProperty(name: name, property: property)
//        return current.isEmpty ? propStr : "\(current),\(propStr)"
//    }
//
//    static func appendProperty(_ current:String, name: String, property:Bool) -> String {
//        let propStr = writeProperty(name: name, property: property)
//        return current.isEmpty ? propStr : "\(current),\(propStr)"
//    }

    static func writeProperty<T: CustomStringConvertible>(name:String, property:T) -> String {
        return "\"\(name)\":\"\(property.description)\""
    }
    
//    static func writeProperty(name:String, property:String) -> String {
//        return "\"\(name)\":\"\(property)\""
//    }
//
//    static func writeProperty(name:String, property:Int16) -> String {
//        return "\"\(name)\":\"\(property)\""
//    }
//
//    static func writeProperty(name:String, property:Bool) -> String {
//        let val = property ? "ON":"OFF"
//        return writeProperty(name: name, property: val)
//    }

    static func wrapObject(name:String, objectJSON:String) -> String {
        return "\"\(name)\":{\(objectJSON)}"
    }
    
    static func appendObject(_ current:String, objectJSON:String) -> String {
        return current.isEmpty ? "\(objectJSON)" : "\(current),\(objectJSON)"
    }
    
    static func wrapArray(name:String, arrayJSON: String) -> String {
        return "\"\(name)\":[\(arrayJSON)]"
    }
}
